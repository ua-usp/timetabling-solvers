// STD
#include <iostream>
#include <vector>
#include <memory>
#include <fstream>

// CHRPP
#include <chrpp.hh>
#include <bt_interval.hh>

// TIMETABLING MODEL
#include <timetabling_chr_header.hpp>

// JSON
#include "nlohmann-json/json.hpp"
using json = nlohmann::json;

// PARSER
#include "instanceparser.h"

/*
 * Arguments parsing
 */
std::vector< std::string > args;
void parseArgs(int argc, const char **argv) {
    if(args.empty()) { // We can parse args only once
        for(int i=0; i<argc; ++i) {
            args.push_back(argv[i]);
        }
    }
}
bool argExists(std::string arg) {
    return std::find(args.begin(), args.end(), arg) != args.end();
}
std::string getArg(std::string arg) {
    auto it = std::find(args.begin(), args.end(), arg);
    if(it != args.end() && ++it != args.end()) {
        return *it;
    }
    return std::string("");
}

int main(int argc, const char **argv)
{
    std::string jsonFilename;
    bool filterRules = false;
    std::vector<int> allowedRules;

    parseArgs(argc, argv);
    if(!argExists("-i")) {
        std::cerr << "ERROR: You have to give the input JSON file (-i <jsonFileName>)." << std::endl;
        return 1;
    }
    jsonFilename = getArg("-i");

    if(argExists("--rules")) {
        filterRules = true;

        std::string rules = getArg("--rules");

        std::string::size_type start = 0;
        std::string::size_type end = rules.find(",");
        while(end != std::string::npos) {
            allowedRules.push_back(std::stoi(rules.substr(start, end - start)));
            start = end+1;
            end = rules.find(",", start);
        }
        allowedRules.push_back(std::stoi(rules.substr(start, end - start)));
    }

    TRACE(
                unsigned int traceFlags = chr::Log::NONE;

                if(argExists("-tALL")) {
                    traceFlags |= chr::Log::ALL;
                }
                if(argExists("-tAPPLY")) {
                    traceFlags |= chr::Log::APPLY;
                }
                if(argExists("-tBACKTRACK")) {
                    traceFlags |= chr::Log::BACKTRACK;
                }
                if(argExists("-tCALL")) {
                    traceFlags |= chr::Log::CALL;
                }
                if(argExists("-tCOMMIT")) {
                    traceFlags |= chr::Log::COMMIT;
                }
                if(argExists("-tEXECUTE")) {
                    traceFlags |= chr::Log::EXECUTE;
                }
                if(argExists("-tEXIT")) {
                    traceFlags |= chr::Log::EXIT;
                }
                if(argExists("-tFAIL")) {
                    traceFlags |= chr::Log::FAIL;
                }
                if(argExists("-tGOAL")) {
                    traceFlags |= chr::Log::GOAL;
                }
                if(argExists("-tHISTORY")) {
                    traceFlags |= chr::Log::HISTORY;
                }
                if(argExists("-tINSERT")) {
                    traceFlags |= chr::Log::INSERT;
                }
                if(argExists("-tPARTNER")) {
                    traceFlags |= chr::Log::PARTNER;
                }
                if(argExists("-tREMOVE")) {
                    traceFlags |= chr::Log::REMOVE;
                }
                if(argExists("-tTRY")) {
                    traceFlags |= chr::Log::TRY;
                }
                if(argExists("-tWAKE")) {
                    traceFlags |= chr::Log::WAKE;
                }

                chr::Log::register_flags(traceFlags);
            ); // end TRACE

    ///////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////

    // First we read the JSON file
    std::ifstream jsonInputFile(jsonFilename);
    json jFile;

    if(!jsonInputFile.good() || !jsonInputFile.is_open()) {
        std::cerr << "Impossible d'ouvrir le fichier '" << jsonFilename << "'" << std::endl;
        return 1;
    }

    jsonInputFile >> jFile;

    // Then we link it to the CHR model
    TIMETABLING mySpace;

    CHR_RUN(
        apply(jFile, mySpace, filterRules, allowedRules);

        if(!chr::failed()) {
            mySpace.go();
        }
    );

    chr::Statistics::print(std::cout);

    std::cout << std::endl;

    if(chr::failed()) {
        std::cout << "===[ FAILED ]===" << std::endl;
        mySpace.print();
        mySpace.print_outputs();
        std::cout << "===[ FAILED ]===" << std::endl;
    } else {
        std::cout << "===[ SUCCEEDED ]===" << std::endl;
        mySpace.print();
        mySpace.print_outputs();
        std::cout << "===[ SUCCEEDED ]===" << std::endl;
    }

    chr::Statistics::print(std::cout);

    return 0;
}

