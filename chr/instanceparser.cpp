#include "instanceparser.h"

using json = nlohmann::json;

#include <iostream>

bool exists(json &obj, std::string key) {
    return obj.is_object() && obj[key] != nullptr;
}

bool exists(json &obj, std::vector<std::string> const &keys) {
    if(!obj.is_object()) {
        return false;
    }

    for(auto &key : keys) {
        if(obj[key] == nullptr) {
            return false;
        }
    }

    return true;
}

template <typename T>
bool inVector(std::vector< T > const &collection, T const &value) {
    return std::find(collection.begin(), collection.end(), value) != collection.end();
}

chr::ES_CHR apply(json &file, TIMETABLING &space, bool filterRules, const std::vector<int> &allowedRules) {
    // IDs in the JSON file start at 1,
    // IDs in CHRPP start at 0
    //
    // Root structure of JSON file :
    // PADDING (TODO: not used in this solver yet)
    // DATA (mandatory)
    // RULES (not used in this solver)
    // SOLUTION
    // - GROUPES (mandatory for this solver)
    // - CLASSES (mandatory for this solver)
    // - SESSIONS
    // CONSTRAINTS

    std::vector<std::string> data_required_keys({"nr_weeks", "nr_days_per_week", "nr_slots_per_day", "nr_courses", "nr_parts", "course_parts", "nr_classes", "part_classes", "nr_sessions", "max_part_sessions", "part_nr_sessions", "nr_equipments", "nr_rooms", "nr_teachers", "nr_groups", "nr_part_rooms", "part_rooms", "nr_part_teachers", "part_teachers", "part_dailyslots", "part_days", "part_weeks", "class_groups", "part_session_length", "max_equipment_count", "max_class_maxheadcount", "max_teacher_session", "max_teacher_sessions", "equipment_count", "max_room_capacity", "room_capacity", "part_room_use", "nr_part_room_mandatory", "part_room_mandatory", "part_teacher_sessions_count", "part_session_teacher_count", "class_maxheadcount", "class_parent", "student_courses", "equipment_name", "room_name", "teacher_name", "student_name", "course_name", "part_name", "class_name", "nr_labels", "label_name", "room_label", "teacher_label", "student_label", "course_label", "part_label"});
    std::vector<std::string> rules_required_keys({"nr_rules", "nr_scopes", "rule_scopes", "scope_type", "mask_length", "scope_mask", "nr_filters", "scope_filters", "filter_type", "filter_elements", "rule_constraint", "constraint_hardness", "nr_parameters", "constraint_parameters", "parameter_name", "parameter_type", "max_parameter_size", "parameter_value"});
    std::vector<std::string> solution_groups_required_keys({"nr_groups", "max_group_headcount", "group_headcount", "group_name", "group_students"});
    std::vector<std::string> solution_classes_required_keys({"class_teachers", "class_rooms", "class_groups"});
    std::vector<std::string> solution_sessions_required_keys({"session_dailyslot", "session_day", "session_week", "session_rooms", "session_teachers"});
    std::vector<std::string> constraint_required_keys({"rule", "constraint", "hardness", "arity", "types", "elements", "t-sessions", "parameters"});

    // First we do some sanity checks on the JSON structure:
    if(!exists(file, "DATA")) {
        std::cerr << "ERROR: Missing the DATA key." << std::endl;
        return chr::failure();
    }
    json data = file["DATA"];

    if(!exists(data, data_required_keys)) {
        std::cerr << "ERROR: Missing at least one of the following required keys in DATA:" << std::endl;
        for(auto &key : data_required_keys) {
            std::cerr << key << " ";
        }
        std::cerr << std::endl;
        return chr::failure();
    }

    if(!exists(file, "SOLUTION")) {
        std::cerr << "ERROR: Missing the SOLUTION key." << std::endl;
        return chr::failure();
    }
    json solution = file["SOLUTION"];

    if(!exists(solution, "GROUPES")) {
        std::cerr << "ERROR: Missing the GROUPES key in SOLUTION." << std::endl;
        return chr::failure();
    }
    json sol_groups = solution["GROUPES"];

    if(!exists(solution, "CLASSES")) {
        std::cerr << "ERROR: Missing the CLASSES key in SOLUTION." << std::endl;
        return chr::failure();
    }
    json sol_classes = solution["CLASSES"];

    if(!exists(sol_groups, solution_groups_required_keys)) {
        std::cerr << "ERROR: Missing at least one of the following required keys in SOLUTION > GROUPES:" << std::endl;
        for(auto &key : solution_groups_required_keys) {
            std::cerr << key << " ";
        }
        std::cerr << std::endl;
        return chr::failure();
    }
    if(!exists(sol_classes, solution_classes_required_keys)) {
        std::cerr << "ERROR: Missing at least one of the following required keys in SOLUTION > CLASSES:" << std::endl;
        for(auto &key : solution_classes_required_keys) {
            std::cerr << key << " ";
        }
        std::cerr << std::endl;
        return chr::failure();
    }

    // Time-grid
    int nr_weeks = data["nr_weeks"].get<int>();
    int nr_days_per_week = data["nr_days_per_week"].get<int>();
    int nr_slots_per_day = data["nr_slots_per_day"].get<int>();

    int firstSlot = 0;
    int lastSlot = nr_weeks * nr_days_per_week * nr_slots_per_day - 1;

    space.initNrSlots(lastSlot+1);
    space.initDaysPerWeek(nr_days_per_week);
    space.initSlotsPerDay(nr_slots_per_day);
    space.initSlotsPerWeek(nr_slots_per_day * nr_days_per_week);

    // Rooms
    std::vector<int> roomCapacities;
    for(size_t roomId=0; roomId<data["room_capacity"].size(); ++roomId) {
        int room_capacity = data["room_capacity"][roomId].get<int>();
        CHECK_ES( space.room_capacity(roomId, room_capacity) );
        roomCapacities.push_back(room_capacity);
    }
    space.initRoomCapacities(roomCapacities);

    // Groups
    for(size_t groupId=0; groupId<sol_groups["group_headcount"].size(); ++groupId) {
        CHECK_ES( space.group_size(groupId, sol_groups["group_headcount"][groupId].get<int>()) );
    }

    // Groups registration
    for(size_t classId=0; classId < sol_classes["class_groups"].size(); ++classId) {
        std::vector<int> registeredGroups;
        for(auto &groupJsonId: sol_classes["class_groups"][classId]["set"]) {
            registeredGroups.push_back(groupJsonId.get<int>()-1); // /!\ JSON_ID = CHRPP_ID + 1
        }
        CHECK_ES( space.initClass(classId, registeredGroups) );
    }

    // Session & class declaration
    int sessionId=0;
    std::vector<std::string> sessionIds; // TODO: useless?
    for(int partId=0; partId<data["nr_parts"].get<int>(); ++partId) {
        int sessionLength = data["part_session_length"][partId].get<int>();
        int partFirstSessionId = sessionId;

        // Build allowed slots:
        // 1. We retrieve the dailySlots, days and weeks
        std::vector<int> dailySlots;
        std::vector<int> days;
        std::vector<int> weeks;
        // /!\ JSON starts identifying slots, days and weeks at 1 ; CHRPP starts at 0
        for(auto &ds : data["part_dailyslots"][partId]["set"]) {
            dailySlots.push_back(ds.get<int>()-1);
        }
        for(auto &d : data["part_days"][partId]["set"]) {
            days.push_back(d.get<int>()-1);
        }
        for(auto &w : data["part_weeks"][partId]["set"]) {
            weeks.push_back(w.get<int>()-1);
        }
        // 2. Then we create an interval, and remove all unwanted values
        chr::Interval<int, false> allowedSlots(firstSlot, lastSlot);
        // We remove all the intervals between two allowedSlots:
        int lastAllowed=firstSlot-1;
        for(auto &week : weeks) {
            for (auto &day : days) {
                for(auto &dailySlot : dailySlots) {
                    int allowedSlot = week * nr_slots_per_day * nr_days_per_week + day * nr_slots_per_day + dailySlot;
                    if(lastAllowed+1 <= allowedSlot-1) {
                        allowedSlots.minus(chr::Interval<int, false>(lastAllowed+1, allowedSlot-1));
                    }
                    lastAllowed = allowedSlot;
                }
            }
        }
        if(lastAllowed+1 <= lastSlot) {
            allowedSlots.minus(chr::Interval<int, false>(lastAllowed+1, lastSlot));
        }

        // Create sessions for each class
        for(auto &classJsonId : data["part_classes"][partId]["set"]) {
            int classIndex = classJsonId.get<int>()-1;
            for(size_t index=0; index<data["part_nr_sessions"][partId]; ++index) {
                CHECK_ES( space.initSession(sessionId, classIndex, index) ); // /!\ JSON_ID = CHRPP_ID + 1

                chr::Logical_var_mutable< chr::Interval< int, false > > slotDomain(chr::Interval<>(allowedSlots, 0));
                CHECK_ES( space.initSessionSlot(sessionId, slotDomain, sessionLength) );

                sessionIds.push_back(std::to_string(sessionId)+" - "+data["class_name"][classJsonId.get<int>()-1].get<std::string>()+":"+std::to_string(index));

                // In a class, all the sessions are ordered:
                if(index>0) {
                    CHECK_ES( space.precedence(sessionId-1, sessionId) );
                }

                sessionId++;
            }
        }

        // Teachers
        // We need to know the teacher IDs of the available teachers for the part
        // Those IDs will be the domain of each session_teacher
        // We also need to know those ID to link them to a capacity constraint
        // The vector is used for C++, the Interval and Logical_var for CHR++
        std::vector<int> teacherIds;
        // We build the availableTeachers by the negation
        // First we have all the unwanted teachers
        chr::Interval<int, false> unwantedTeachers(0, data["nr_teachers"].get<int>()-1);
        for(auto &teacherJsonId : data["part_teachers"][partId]["set"]) {
            // /!\ JSON_ID = CHRPP_ID + 1
            // We get rid of the ones that we want
            unwantedTeachers.nq(teacherJsonId.get<int>()-1);
            // And we store the ones we want
            teacherIds.push_back(teacherJsonId.get<int>()-1);
        }
        // We build the availableTeachers by the negation of the unwanted ones
        chr::Interval<int, false> availableTeachers(0, data["nr_teachers"].get<int>()-1);
        availableTeachers.minus(unwantedTeachers);
        // Store all the sessions that one teacher could teach:
        // The keys of this map are teacherIds
        std::map< int, std::vector< chr::Logical_var_mutable< chr::Interval< int, false > > > > teacherSessions;

        // Rooms
        std::vector<int> allowedRooms;
        for(auto &roomJsonId : data["part_rooms"][partId]["set"]) {
            allowedRooms.push_back(roomJsonId.get<int>()-1); // /!\ JSON_ID = CHRPP_ID + 1
        }
        // we will go through sessions again
        int sessId_room = partFirstSessionId;
        int sessId_teacher = partFirstSessionId;
        for(auto &classJsonId : data["part_classes"][partId]["set"]) { // /!\ JSON_ID = CHRPP_ID + 1
            if(data["part_room_use"][partId].get<std::string>() == "single") { // sessionRooms="single"
                // The groups of the same class share the same room
                chr::Interval< int, false > availableRooms(0, roomCapacities.size()-1);

                // We compute the size of the merged groups
                int groups_capacity = 0;
                for(auto &groupJsonId : sol_classes["class_groups"][classJsonId.get<int>()-1]["set"]) { // /!\ JSON_ID = CHRPP_ID + 1
                    groups_capacity += sol_groups["group_headcount"][groupJsonId.get<int>()-1].get<int>();
                }

                for(size_t roomId=0; roomId<roomCapacities.size(); ++roomId) {
                    // We get rid of the ones that were not specified
                    // and the one that could not fit all the groups
                    if(!inVector(allowedRooms, static_cast<int>(roomId)) || data["room_capacity"][roomId].get<int>() < groups_capacity) {
                        availableRooms.nq(roomId);
                    }
                }


                for(size_t index=0; index<data["part_nr_sessions"][partId]; ++index) {
                    chr::Logical_var_mutable rooms(chr::Interval<>(availableRooms, 0)); // All the groups share the same room, so we post the same logical variable for the groups
                    for(auto &groupJsonId : sol_classes["class_groups"][classJsonId.get<int>()-1]["set"]) {
                        CHECK_ES( space.initSessionGroupRoom(sessId_room, groupJsonId.get<int>()-1, rooms) );
                    }

                    sessId_room++;
                }
            } else { // sessionRooms="multiple"
                // Each group can be in a different room
                for(size_t index=0; index<data["part_nr_sessions"][partId]; ++index) {
                    for(auto &groupJsonId : sol_classes["class_groups"][classJsonId.get<int>()-1]["set"]) {
                        chr::Interval<int, false> availableRooms(0, roomCapacities.size()-1);
                        for(size_t roomId=0; roomId<roomCapacities.size(); ++roomId) {
                            // We get rid of the ones that were not specified
                            // and the one that could not fit the group
                            if(!inVector(allowedRooms, static_cast<int>(roomId)) || data["room_capacity"][roomId].get<int>() < sol_groups["group_headcount"][groupJsonId.get<int>()-1].get<int>()) {
                                availableRooms.nq(roomId);
                            }
                        }

                        chr::Logical_var_mutable rooms(chr::Interval<>(availableRooms, 0));
                        CHECK_ES( space.initSessionGroupRoom(sessId_room, groupJsonId.get<int>()-1, rooms) );
                    }

                    sessId_room++;
                }
            } // end sessionRooms

            // Teachers
            // We post as many session_teacher as needed
            for(size_t index=0; index<data["part_nr_sessions"][partId].get<size_t>(); ++index) {
                for(int teacherIndex=0; teacherIndex<data["part_session_teacher_count"][partId].get<int>(); ++teacherIndex) { // /!\ JSON_ID = CHRPP_ID + 1
                    chr::Logical_var_mutable teacher(chr::Interval<>(availableTeachers, 0));
                    CHECK_ES( space.initSessionTeacher(sessId_teacher, teacherIndex, teacher) );

                    // We add this teacher domain to all the teachers of the part
                    for(auto &tid : teacherIds) {
                        teacherSessions[tid].push_back(teacher);
                    }
                }

                CHECK_ES( space.initSessionNrTeachers(sessId_teacher, data["part_session_teacher_count"][partId].get<int>()) );

                sessId_teacher++;
            }
        } // end classJsonId

        // Teachers
        // We put the count of each sessionTeacher here
        for(auto& ts : teacherSessions) {
            int teacher_id = ts.first;
            int teacher_nrSessions = data["part_teacher_sessions_count"][partId][teacher_id].get<int>();
            CHECK_ES( space.capacity(teacher_id, teacher_nrSessions, teacher_nrSessions, ts.second) );
        }

    } // end partId

    CHECK_ES( space.initSessionIds(sessionIds) );

    //* DEBUG ML
    std::cout << "DEBUG ML - session names : " << std::endl;
    for(auto& sname : sessionIds) {
        std::cout << sname << std::endl;
    }
    // END DEBUG ML
    //*/

    // Constraints
    // TODO: post constraints before data?
    if(exists(file, "CONSTRAINTS")) {
        int debugConstraintId=-1;

        if(!exists(file, "RULES")) {
            std::cerr << "ERROR: Missing the RULES key." << std::endl;
            return chr::failure();
        }
        json rules = file["RULES"];
        if(!exists(rules, rules_required_keys)) {
            std::cerr << "ERROR: Missing at least one of the following required keys in RULES:" << std::endl;
            for(auto &key : rules_required_keys) {
                std::cerr << key << " ";
            }
            std::cerr << std::endl;
            return chr::failure();
        }

        for(auto &constraintJson : file["CONSTRAINTS"]) {
            debugConstraintId++;

            if(!exists(constraintJson, constraint_required_keys)) {
                std::cerr << "ERROR: Missing at least one of the following required keys in CONSTRAINTS > " << debugConstraintId << ":" << std::endl;
                for(auto &key : constraint_required_keys) {
                    std::cerr << key << " ";
                }
                std::cerr << std::endl;
                return chr::failure();
            }

            // DEBUG ML
            if(filterRules && std::find(allowedRules.begin(), allowedRules.end(), constraintJson["rule"].get<int>()) == allowedRules.end()) {
                continue;
            }
            // END DEBUG ML

            std::string constraintName = constraintJson["constraint"];

            // TODO: something better than if/else if/else if/...
            if(constraintName == "weekly") {
                std::vector<int> sessionIds;
                int i_sessions=0;
                while(i_sessions < constraintJson["arity"]) {
                    auto &jsonIds = constraintJson["t-sessions"][i_sessions];
                    size_t i=0;
                    while(i<jsonIds.size() && jsonIds[i].get<int>() != 0) {
                        sessionIds.push_back(jsonIds[i].get<int>()-1);  // /!\ JSON_ID = CHRPP_ID + 1
                        ++i;
                    }
                    ++i_sessions;
                }

                CHECK_ES( space.weekly(sessionIds) );
            } else if(constraintName == "sequenced") {
                int arity = constraintJson["arity"].get<int>();
                switch(arity) {
                case 1: {
                    int session_id_save=0;

                    auto &ids = constraintJson["t-sessions"][0];
                    size_t i=1;

                    session_id_save = ids[0].get<int>();
                    while(i<ids.size() && ids[i].get<int>() != 0) {
                        CHECK_ES( space.precedence(session_id_save-1, ids[i].get<int>()-1) ); // /!\ JSON_ID = CHRPP_ID + 1
                        session_id_save = ids[i];
                        ++i;
                    }
                    break;
                }
                case 2: {
                    auto &ids1 = constraintJson["t-sessions"][0];
                    auto &ids2 = constraintJson["t-sessions"][1];

                    size_t i1=0;
                    while(i1 < ids1.size() && ids1[i1] != 0) {
                        size_t i2=0;
                        while(i2 < ids2.size() && ids2[i2] != 0) {
                            CHECK_ES( space.precedence(ids1[i1].get<int>()-1, ids2[i2].get<int>()-1) ); // /!\ JSON_ID = CHRPP_ID + 1
                            ++i2;
                        }
                        ++i1;
                    }
                    break;
                }
                default: {
                    if(arity < 3) {
                        std::cerr << "WARNING: constraint 'sequenced' (" << debugConstraintId << ") has invalid arity." << std::endl;
                        break;
                    }
                    // If the `sequenced` constraint has an arity > 2:
                    // all the sessions of one set must be before all the session of the next set
                    for(int a = 0; a<arity-1; ++a) {
                        auto &ids1 = constraintJson["t-sessions"][a];
                        auto &ids2 = constraintJson["t-sessions"][a+1];

                        size_t i1=0;
                        while(i1 < ids1.size() && ids1[i1] != 0) {
                            size_t i2=0;
                            while(i2 < ids2.size() && ids2[i2] != 0) {
                                CHECK_ES( space.precedence(ids1[i1].get<int>()-1, ids2[i2].get<int>()-1) ); // /!\ JSON_ID = CHRPP_ID + 1
                                ++i2;
                            }
                            ++i1;
                        }
                    }
                    break;
                }
                }
            } else if(constraintName == "same_rooms") {
                std::vector<int> sessionIds;
                int i_sessions=0;
                while(i_sessions < constraintJson["arity"]) {
                    auto &jsonIds = constraintJson["t-sessions"][i_sessions];
                    size_t i=0;
                    while(i<jsonIds.size() && jsonIds[i].get<int>() != 0) {
                        sessionIds.push_back(jsonIds[i].get<int>()-1);  // /!\ JSON_ID = CHRPP_ID + 1
                        ++i;
                    }
                    ++i_sessions;
                }

                CHECK_ES( space.sameRoom(sessionIds) );
            } else if(constraintName == "same_week") {
                std::vector<int> sessionIds;
                int i_sessions=0;
                while(i_sessions < constraintJson["arity"]) {
                    auto &jsonIds = constraintJson["t-sessions"][i_sessions];
                    size_t i=0;
                    while(i<jsonIds.size() && jsonIds[i].get<int>() != 0) {
                        sessionIds.push_back(jsonIds[i].get<int>()-1);  // /!\ JSON_ID = CHRPP_ID + 1
                        ++i;
                    }
                    ++i_sessions;
                }

                CHECK_ES( space.sameWeek(sessionIds) );
            } else if(constraintName == "same_teachers") {
                std::vector<int> sessionIds;
                int i_sessions=0;
                while(i_sessions < constraintJson["arity"]) {
                    auto &jsonIds = constraintJson["t-sessions"][i_sessions];
                    size_t i=0;
                    while(i<jsonIds.size() && jsonIds[i].get<int>() != 0) {
                        sessionIds.push_back(jsonIds[i].get<int>()-1);  // /!\ JSON_ID = CHRPP_ID + 1
                        ++i;
                    }
                    ++i_sessions;
                }

                CHECK_ES( space.sameTeachers(sessionIds) );
            } else if(constraintName == "same_slots") {
                std::vector<int> sessionIds;
                int i_sessions=0;
                while(i_sessions < constraintJson["arity"]) {
                    auto &jsonIds = constraintJson["t-sessions"][i_sessions];
                    size_t i=0;
                    while(i<jsonIds.size() && jsonIds[i].get<int>() != 0) {
                        sessionIds.push_back(jsonIds[i].get<int>()-1);  // /!\ JSON_ID = CHRPP_ID + 1
                        ++i;
                    }
                    ++i_sessions;
                }

                CHECK_ES( space.sameStart(sessionIds) );
            } else if(constraintName == "not_consecutive_rooms") {
                // TODO
                std::cerr << "WARNING: constraint 'not_consecutive_rooms' (" << debugConstraintId << ") not implemented yet." << std::endl;
            } else if(constraintName == "at_most_daily") {
                int const nb_params = 3;
                if(constraintJson["parameters"].size() != nb_params) {
                    std::cerr << "WARNING: constraint 'at_most_daily' (" << debugConstraintId << ") invalid number of parameters (found "<<constraintJson["parameters"].size()<<", expected "<<nb_params<<")." << std::endl;
                    continue;
                }

                if(constraintJson["arity"] != 1) {
                    std::cerr << "WARNING: constraint 'at_most_daily' (" << debugConstraintId << ") invalid arity." << std::endl;
                    continue;
                }

                std::map<std::string, int> params;
                params["count"] = 0;
                params["first"] = 0;
                params["last"] = 0;

                // read params values:
                for(auto &paramJsonId : constraintJson["parameters"]) {
                    int paramId = paramJsonId.get<int>()-1;  // /!\ JSON_ID = CHRPP_ID + 1
                    // parameter_value is a matrix [max_nb_parameters, max_size_parameter]
                    // in our case (at_most_daily), the parameters are all of size 1
                    // so we only look at the first value
                    params[ rules["parameter_name"][paramId].get<std::string>() ] = rules["parameter_value"][paramId][0].get<int>();
                }

                int count = params["count"];
                // in parameters, slots begin at 1, in CHR they begin at 0
                int first = params["first"]-1;
                int last = params["last"]-1;

                std::vector<int> sessionIds;
                auto &jsonIds = constraintJson["t-sessions"][0];
                size_t i=0;
                while(i<jsonIds.size() && jsonIds[i].get<int>() != 0) {
                    sessionIds.push_back(jsonIds[i].get<int>()-1);  // /!\ JSON_ID = CHRPP_ID + 1
                    ++i;
                }

                if(constraintJson["types"][0].get<std::string>() == "teacher") {
                    int teacherId = constraintJson["elements"][0].get<int>()-1;

                    // we post a constraint for each day of the time horizon
                    for(int day=0; day<nr_days_per_week*nr_weeks; ++day) {
                        CHECK_ES( space.atMostTeacher(sessionIds, count, day*nr_slots_per_day+first, day*nr_slots_per_day+last, teacherId) );
                    }
                } else {
                    // TODO
                    std::cerr << "WARNING: constraint 'at_most_daily' (" << debugConstraintId << ") not implemented yet." << std::endl;
                }
            } else {
                std::cerr << "WARNING: constraint '" << constraintName << "' (" << debugConstraintId << ") unknown." << std::endl;
            }
        }
    } // END Constraints

    // Is there a (partial) solution?
    if(exists(solution, "SESSIONS")) {
        json sol_sessions = solution["SESSIONS"];

        if(!exists(sol_sessions, solution_sessions_required_keys)) {
            std::cerr << "ERROR: Missing at least one of the following required keys in SOLUTION > SESSIONS:" << std::endl;
            for(auto &key : solution_sessions_required_keys) {
                std::cerr << key << " ";
            }
            std::cerr << std::endl;
            return chr::failure();
        }

        for(size_t classId=0; classId<data["nr_classes"].get<size_t>(); ++classId) {
            for(size_t sessionIndex=0; sessionIndex<sol_sessions["session_dailyslot"][classId].size(); ++sessionIndex) {

                // SESSIONS:
                int sol_dailyslot = sol_sessions["session_dailyslot"][classId][sessionIndex].get<int>();
                int sol_day = sol_sessions["session_day"][classId][sessionIndex].get<int>();
                int sol_week = sol_sessions["session_week"][classId][sessionIndex].get<int>();
                // SessionIndex does not exist:
                if((sol_dailyslot == -1) || (sol_day == -1) || (sol_week == -1)) { // TODO use PADDING
                    continue;
                }
                // Session slot is not fixed:
                if((sol_dailyslot == 0) || (sol_day == 0) || (sol_week == 0)) { // TODO use PADDING
                    continue;
                }

                // /!\ JSON_ID = CHRPP_ID + 1:
                sol_dailyslot--;
                sol_day--;
                sol_week--;

                CHECK_ES( space.solutionSessionSlot(classId, sessionIndex, sol_dailyslot, sol_day, sol_week) );

                // TODO ROOMS:

                // TEACHERS:
                int teacherIndex=0;
                for(auto &teacherJsonId : sol_sessions["session_teachers"][classId][sessionIndex]["set"]) {
                    int teacherId = teacherJsonId.get<int>();
                    if(teacherId != 0) { // TODO use PADDING
                        teacherId--; // /!\ JSON_ID = CHRPP_ID + 1

                        CHECK_ES( space.solutionTeacher(classId, sessionIndex, teacherIndex, teacherId) );
                        teacherIndex++;
                    }
                }
            }
        }

    }

    return chr::success();
}
