#include "cp_int.h"
#include <string>

// Modify both i1 and i2 to make them the intersection between the two
chr::ES_CHR CP::Int::narrow(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, chr::Logical_var_mutable< chr::Interval<int, false> > &i2) {
    bool modified=false;

    if((*i1).singleton()) {
        return i2.update_mutable(modified, [&modified,i1](auto& intvl2) {
            modified = intvl2.eq((*i1).val());
        });
    }

    if((*i2).singleton()) {
        return i1.update_mutable(modified, [&modified,i2](auto& intvl1) {
            modified = intvl1.eq((*i2).val());
        });
    }

    // both intervals are not singletons,
    // we must narrow both intervals to the intersection

    // First we narrow i1
    chr::ES_CHR update_i1 = i1.update_mutable(modified, [&modified,i2](auto& intvl1) {
        modified = intvl1.narrow(*i2);
    });
    if(update_i1 == chr::ES_CHR::FAILURE) {
        return chr::ES_CHR::FAILURE;
    }

    if((*i1).empty()) {
        return chr::failure();
    }

    // Then i2
    return i2.update_mutable(modified, [&modified,i1](auto& intvl2) {
        modified = intvl2.narrow(*i1);
    });
}

chr::ES_CHR CP::Int::eq(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, chr::Logical_var_mutable< chr::Interval<int, false> > &i2) {
    if((*i1).singleton()) {
        return eq(i2, (*i1).val());
    }

    if((*i2).singleton()) {
        return eq(i1, (*i2).val());
    }

    // both intervals are not singletons
    bool modified=false;
    chr::ES_CHR update_i1 = i1.update_mutable(modified, [&modified,i2](auto& intvl1) {
        //TODO: Optimize with ranges
        for(int v2=(*i2).min(); v2<=(*i2).max(); ++v2) {
            if(!(*i2).in(v2)) {
                modified |= intvl1.nq(v2);
            }
        }
    });
    if(update_i1 == chr::ES_CHR::FAILURE) {
        return chr::ES_CHR::FAILURE;
    }

    if((*i1).empty()) {
        return chr::failure();
    }

    return i2.update_mutable(modified, [&modified, i1](auto& intvl2) {
        //TODO: Optimize with ranges
        for(int v1=(*i1).min(); v1<=(*i1).max(); ++v1) {
            if(!(*i1).in(v1)) {
                modified |= intvl2.nq(v1);
            }
        }
    });
}

chr::ES_CHR CP::Int::eq(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, int v2) {
    bool modified=false;
    return i1.update_mutable(modified, [&modified,v2](auto& intvl1){
        modified = intvl1.eq(v2);
    });
}

chr::ES_CHR CP::Int::ne(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, chr::Logical_var_mutable< chr::Interval<int, false> > &i2) {
    bool modified=false;
    if((*i1).singleton()) {
        return i2.update_mutable(modified, [&modified,i1](auto& intvl2) {
            modified = intvl2.nq((*i1).val());
        });
    }

    if((*i2).singleton()) {
        return i1.update_mutable(modified, [&modified,i2](auto& intvl1) {
            modified = intvl1.nq((*i2).val());
        });
    }

    // both intervals are not singletons
    // we can't propagate anything!

    return chr::success();
}

chr::ES_CHR CP::Int::ne(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, int v2) {
    bool modified=false;
    return i1.update_mutable(modified, [&modified,v2](auto& intvl1) {
        modified = intvl1.nq(v2);
    });
}

chr::ES_CHR CP::Int::ne(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, int removeFrom, int removeTo) {
    bool modified=false;
    return i1.update_mutable(modified, [&modified,removeFrom,removeTo](auto& intvl1) {
       modified = intvl1.minus(chr::Interval<int, false>(removeFrom, removeTo));
    });
}

chr::ES_CHR CP::Int::lt(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, chr::Logical_var_mutable< chr::Interval<int, false> > &i2) {
    bool modified=false;
    if((*i1).singleton()) {
        return i2.update_mutable(modified, [&modified,i1](auto& intvl2) {
            modified = intvl2.gq((*i1).val()+1);
        });
    }

    if((*i2).singleton()) {
        return i1.update_mutable(modified, [&modified,i2](auto& intvl1) {
            modified = intvl1.lq((*i2).val()-1);
        });
    }

    // both intervals are not singletons
    // i1 < i2 means
    // i1 < i2.max and i2 > i1.min
    // we can't say anything else
    chr::ES_CHR update_i1 = i1.update_mutable(modified, [&modified,i2](auto& intvl1) {
        modified = intvl1.lq((*i2).max()-1);
    });
    if(update_i1 == chr::ES_CHR::FAILURE) {
        return chr::ES_CHR::FAILURE;
    }

    if((*i1).empty()) {
        return chr::failure();
    }

    return i2.update_mutable(modified, [&modified, i1](auto& intvl2) {
        modified = intvl2.gq((*i1).min()+1);
    });
}

chr::ES_CHR CP::Int::lt(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, int v2) {
    bool modified=false;
    return i1.update_mutable(modified, [&modified,v2](auto& intvl1) {
        modified = intvl1.lq(v2-1);
    });
}

chr::ES_CHR CP::Int::le(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, chr::Logical_var_mutable< chr::Interval<int, false> > &i2) {
    bool modified=false;
    if((*i1).singleton()) {
        return i2.update_mutable(modified, [&modified,i1](auto& intvl2) {
            modified = intvl2.gq((*i1).val());
        });
    }

    if((*i2).singleton()) {
        return i1.update_mutable(modified, [&modified,i2](auto& intvl1) {
            modified = intvl1.lq((*i2).val());
        });
    }

    // both intervals are not singletons
    // i1 <= i2 means
    // i1 <= i2.max and i2 >= i1.min
    // we can't say anything else
    chr::ES_CHR update_i1 = i1.update_mutable(modified, [&modified,i2](auto& intvl1) {
        modified = intvl1.lq((*i2).max());
    });
    if(update_i1 == chr::ES_CHR::FAILURE) {
        return chr::ES_CHR::FAILURE;
    }

    if((*i1).empty()) {
        return chr::failure();
    }

    return i2.update_mutable(modified, [&modified, i1](auto& intvl2) {
        modified = intvl2.gq((*i1).min());
    });
}

chr::ES_CHR CP::Int::le(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, int v2) {
    bool modified=false;
    return i1.update_mutable(modified, [&modified,v2](auto& intvl1) {
        modified = intvl1.lq(v2);
    });
}

chr::ES_CHR CP::Int::gt(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, chr::Logical_var_mutable< chr::Interval<int, false> > &i2) {
    bool modified=false;
    if((*i1).singleton()) {
        return i2.update_mutable(modified, [&modified,i1](auto& intvl2) {
            modified = intvl2.lq((*i1).val()-1);
        });
    }

    if((*i2).singleton()) {
        return i1.update_mutable(modified, [&modified,i2](auto& intvl1) {
            modified = intvl1.gq((*i2).val()+1);
        });
    }

    // both are ranges
    // i1 > i2 means
    // i1 > i2.min and i2 < i1.max
    // we can't say anything else
    chr::ES_CHR update_i1 = i1.update_mutable(modified, [&modified,i2](auto& intvl1) {
        modified = intvl1.gq((*i2).min()+1);
    });
    if(update_i1 == chr::ES_CHR::FAILURE) {
        return chr::ES_CHR::FAILURE;
    }

    if((*i1).empty()) {
        return chr::failure();
    }

    return i2.update_mutable(modified, [&modified,i1](auto& intvl2) {
        modified = intvl2.lq((*i1).max()-1);
    });
}

chr::ES_CHR CP::Int::gt(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, int v2) {
    bool modified=false;
    return i1.update_mutable(modified, [&modified,v2](auto& intvl1) {
        modified = intvl1.gq(v2+1);
    });
}

chr::ES_CHR CP::Int::ge(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, chr::Logical_var_mutable< chr::Interval<int, false> > &i2) {
    bool modified=false;
    if((*i1).singleton()) {
        return i2.update_mutable(modified, [&modified,i1](auto& intvl2) {
            modified = intvl2.lq((*i1).val());
        });
    }

    if((*i2).singleton()) {
        return i1.update_mutable(modified, [&modified,i2](auto& intvl1) {
            modified = intvl1.gq((*i2).val());
        });
    }

    // both are ranges
    // i1 > i2 means
    // i1 > i2.min and i2 < i1.max
    // we can't say anything else
    chr::ES_CHR update_i1 = i1.update_mutable(modified, [&modified,i2](auto& intvl1) {
        modified = intvl1.gq((*i2).min());
    });
    if(update_i1 == chr::ES_CHR::FAILURE) {
        return chr::ES_CHR::FAILURE;
    }

    if((*i1).empty()) {
        return chr::failure();
    }

    return i2.update_mutable(modified, [&modified,i1](auto& intvl2) {
        modified = intvl2.lq((*i1).max());
    });
}

chr::ES_CHR CP::Int::ge(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, int v2) {
    bool modified=false;
    return i1.update_mutable(modified, [&modified,v2](auto& intvl1) {
        modified = intvl1.gq(v2);
    });
}

/**
 * @brief CP::Int::plus makes sure that i1 + n = i3
 * @param i1
 * @param n
 * @param i3
 * @return
 */
chr::ES_CHR CP::Int::plus(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, int n, chr::Logical_var_mutable< chr::Interval<int, false> > &i3) {
    bool modified=false;
    if((*i1).singleton()) {
        return i3.update_mutable(modified, [&modified, i1, n](auto& intvl3) {
            modified = intvl3.eq((*i1).val()+n);
        });
    }

    if((*i3).singleton()) {
        return i1.update_mutable(modified, [&modified, n,i3](auto& intvl1) {
            modified = intvl1.eq((*i3).val()-n);
        });
    }

    // both intervals are not singletons
    chr::ES_CHR update_i1 = i1.update_mutable(modified, [&modified, n,i3](auto& intvl1) {
		chr::Interval<int, false> iv(*i3,-n);
        modified= intvl1.narrow(iv);
    });

    if(update_i1 == chr::ES_CHR::FAILURE) {
        return chr::ES_CHR::FAILURE;
    }

    if((*i1).empty()) {
        return chr::failure();
    }

    return i3.update_mutable(modified, [&modified,i1,n](auto& intvl3) {
		chr::Interval<int, false> iv(*i1,n);
        modified = intvl3.narrow(iv);
    });
}

/**
 * i1 % n = i3
 */
chr::ES_CHR CP::Int::modulo(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, int n, chr::Logical_var_mutable< chr::Interval<int, false> > &i3) {
    bool modified=false;
    if((*i1).singleton()) {
        return i3.update_mutable(modified, [&modified,i1,n](auto& intvl3) {
            modified = intvl3.eq((*i1).val() % n);
        });
    }

	if((*i3).singleton()) {
        return i1.update_mutable(modified, [&modified,n,i3](auto& intvl1) {
            modified = false;
            int v3 = (*i3).val();
			if (v3 >= n)
			{
				modified = intvl1.eq(intvl1.min() - 1); // Force empty
			} else if (n != 1) {
				auto it1_r = intvl1.range_begin();
				auto it1_r_end = intvl1.range_end();
				while( it1_r != it1_r_end )
				{
					// Get the next relevant value % n
					auto new_inf = (*it1_r).min()%n <= v3?
								(*it1_r).min() + v3 - (*it1_r).min() % n:
								(*it1_r).min() + v3 + n - (*it1_r).min() % n;
					if (new_inf <= (*it1_r).max()) {
						modified |= intvl1.narrow(it1_r, new_inf, (*it1_r).max());
						if ((*it1_r).min() == (*it1_r).max())
							++it1_r;
						else
							modified |= intvl1.nq(it1_r,(*it1_r).min()+1); // Force the split of the interval
					} else
						modified |= intvl1.remove(it1_r);
				}
            }
        });
    }

    // both intervals are not singletons
    chr::ES_CHR update_i1 = i1.update_mutable(modified, [&modified,n,i3](auto& intvl1) {
        modified = false;
		auto it1_r = intvl1.range_begin();
		auto it1_r_end = intvl1.range_end();
		while( it1_r != it1_r_end )
        {
            bool do_nq = false;
			int ir1_min = (*it1_r).min();
			int ir1_max = (*it1_r).max();
			for (int x = ir1_min; x <= ir1_max; ++x)
			{
                if (!(*i3).in(x%n)) {
                    do_nq |= intvl1.nq(it1_r,x);
                }
			}	
			if (do_nq)
				modified = true;
			else
				++it1_r;
        }
    });
    if(update_i1 == chr::ES_CHR::FAILURE) {
        return chr::ES_CHR::FAILURE;
    }

    if((*i1).empty()) {
        return chr::failure();
    }

    return i3.update_mutable(modified, [&modified,i1,n](auto& intvl3) {
        modified = false;
		auto it3_r = intvl3.range_begin();
		auto it3_r_end = intvl3.range_end();
		while( it3_r != it3_r_end )
		{
			bool do_nq = false;
			int ir3_min = (*it3_r).min();
			int ir3_max = (*it3_r).max();
			for (int x = ir3_min; x <= ir3_max; ++x)
			{
				auto it1 = (*i1).begin();
				auto it1_end = (*i1).end();
				while ( (it1 != it1_end) && ((*it1)%n != x) ) ++it1;

				if (it1 == it1_end)
					do_nq |= intvl3.nq(it3_r,x);
			}
			if (do_nq)
				modified = true;
			else
				++it3_r;
        }
    });
}

chr::ES_CHR CP::Int::modulo_boundConsistency(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, int v2, chr::Logical_var_mutable< chr::Interval<int, false> > &i3) {
    bool modified=false;
    chr::ES_CHR update_i1 = i1.update_mutable(modified, [&modified, v2, i3](auto& intvl1) {
        modified = false;

        // First the min bound
        if(intvl1.min() % v2 < (*i3).min()) { // min(i1)%v2 is lower than i3
            // it has to be greater than min(i3) -- modulo v2
            modified |= intvl1.gq(intvl1.min() + (*i3).min() - intvl1.min() % v2);
        } else if(intvl1.min() % v2 > (*i3).max()) { // min(i1) is greater than i3
            // it has to be greater than the next min(i3) -- modulo v2
            modified |= intvl1.gq(intvl1.min() + (*i3).min() + v2 - intvl1.min() % v2);
        }
        // else: min(i1)%v2 is in the range, nothing to change in i1

        // Before checking the max bound, a sanity check
        if(intvl1.empty()) {
            return;
        }

        // Then the max bound
        if(intvl1.max() % v2 < (*i3).min()) {
            // it has to be lower than the previous max(i3) -- modulo v2
            modified |= intvl1.lq(intvl1.max() - v2 + (*i3).max() - (intvl1.max() % v2));
        } else if(intvl1.max() % v2 > (*i3).max()) {
            // it has to be lower than max(i3) -- moduo v2
            modified |= intvl1.lq(intvl1.max() + (*i3).max() - (intvl1.max() % v2));
        }
    });

    if(update_i1 == chr::ES_CHR::FAILURE) {
        return chr::ES_CHR::FAILURE;
    }

    if((*i1).empty()) {
        return chr::failure();
    }

    return i3.update_mutable(modified, [&modified, i1, v2](auto& intvl3) {
        modified = false;

        // We count how many values are in i1 : if it's >= v2, we can't say anything about bounds
        if((*i1).max() - (*i1).min() + 1 < v2) {
            // We can modify i3 bounds only if the "holes" are in the begining or ending of i3
            // Meaning that i1 % v2 does not "cycle"
            if(((*i1).min() % v2) <= ((*i1).max() % v2)) {
                chr::Interval<int, false> narrowedInterval((*i1).min() % v2, (*i1).max() % v2);
                modified |= intvl3.narrow(narrowedInterval);
            }
        }
    });
}

chr::ES_CHR CP::Int::div_boundConsistency(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, int v2, chr::Logical_var_mutable< chr::Interval<int, false> > &i3) {
    bool modified=false;
    chr::ES_CHR update_i1 = i1.update_mutable(modified, [&modified, v2, i3](auto& intvl1) {
        modified = false;

        // First the min bound
        if(intvl1.min() < (*i3).min() * v2) {
            modified |= intvl1.gq((*i3).min() * v2);
        }

        // Before checking the max bound, a sanity check
        if(intvl1.empty()) {
            return;
        }

        // Then the max bound
        if(intvl1.max() > ((*i3).max()+1) * v2 - 1) {
            modified |= intvl1.lq(((*i3).max()+1) * v2 - 1);
        }
    });

    if(update_i1 == chr::ES_CHR::FAILURE) {
        return chr::ES_CHR::FAILURE;
    }

    if((*i1).empty()) {
        return chr::failure();
    }

    return i3.update_mutable(modified, [&modified, i1, v2](auto& intvl3) {
        modified = false;

        // First the min bound
        if(intvl3.min() < (*i1).min() / v2) {
            intvl3.gq((*i1).min() / v2);
        }

        // Before checking the max bound, a sanity check
        if(intvl3.empty()) {
            return;
        }

        // Then the max bound
        if(intvl3.max() > (*i1).max() / v2) {
            modified |= intvl3.lq((*i1).max() / v2);
        }
    });
}

chr::ES_CHR CP::Int::notin_range(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, int rangeMin, int rangeMax) {
    bool modified=false;
    return i1.update_mutable(modified, [&modified,rangeMin,rangeMax](auto& intvl1) {
			chr::Interval<int, false> iv(rangeMin,rangeMax);
            modified = intvl1.minus(iv);
    });
}

chr::ES_CHR CP::Int::shift_boundConsistency(chr::Logical_var_mutable< chr::Interval<int, false> > &i1, chr::Logical_var_mutable< chr::Interval<int, false> > &i2, int offset) {
    bool modified=false;
    chr::ES_CHR update_i1 = i1.update_mutable(modified, [&modified, i2, offset](auto& intvl1) {
        modified = false;
        if(intvl1.min() < (*i2).min()-offset) {
            modified |= intvl1.gq((*i2).min()-offset);
        }
        if(!intvl1.empty() && intvl1.max() > (*i2).max()-offset) {
            modified |= intvl1.lq((*i2).max()-offset);
        }
    });

    if(update_i1 == chr::ES_CHR::FAILURE) {
        return chr::ES_CHR::FAILURE;
    }

    if((*i1).empty()) {
        return chr::failure();
    }

    return i2.update_mutable(modified, [&modified, i1, offset](auto& intvl2) {
        modified = false;
        if(intvl2.min() < (*i1).min()+offset) {
            modified |= intvl2.gq((*i1).min()+offset);
        }
        if(!intvl2.empty() && intvl2.max() > (*i1).max()+offset) {
            modified |= intvl2.lq((*i1).max()+offset);
        }
    });
}
