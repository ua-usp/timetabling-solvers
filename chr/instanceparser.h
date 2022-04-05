#ifndef INSTANCEPARSER_H
#define INSTANCEPARSER_H

// CHR instance:
#include <timetabling_chr_header.hpp>
// JSON lib:
#include <nlohmann-json/json.hpp>

chr::ES_CHR apply(nlohmann::json &file, TIMETABLING &space, bool filterRules, std::vector<int> const &allowedRules);

#endif // INSTANCEPARSER_H
