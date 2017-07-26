
$offlisting

$include .\Scripts\Preprocessing_for_distance_minimization.gms

*---------------------------------------------------------------------------------------------------------------
*--- running the optimization model
*---------------------------------------------------------------------------------------------------------------

*scalar peso_suavizacao /1000000000/;
scalar peso_suavizacao /1/;

Variables z;

Positive Variable x(codmun_ibge_all, simucont_id_all) 'production area of municipality i to be allocated in simucont_id_all j';

Equations
         cost                                                             'penalty for allocating in distant simus'
         avail_area(simucont_id_all)                                      'available area per simu'
         min_allocation_per_simu(simucont_id_all)                         'minimum allocation per simu'
         total_allocated_area                                             'total allocated area'
         min_allocation_mun_into_simu(codmun_ibge_all, simucont_id_all)   'minimum allocation from municipality into simu'
         mun_prod_area(codmun_ibge_all)                                   'municipality area to be allocated';

cost ..
         Z =E= sum((codmun_ibge_all, simucont_id_all)$valid_dists(codmun_ibge_all, simucont_id_all), x(codmun_ibge_all, simucont_id_all) *
               power(valid_dists(codmun_ibge_all, simucont_id_all), 2)) +
               sum((codmun_ibge_all, simucont_id_all)$(IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMun') and
                                              IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimU') and
                                              ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') and
                                              valid_dist_pairs(codmun_ibge_all, simucont_id_all)),
                   peso_suavizacao * x(codmun_ibge_all, simucont_id_all) * (1 - IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMun')) +
                   peso_suavizacao * x(codmun_ibge_all, simucont_id_all) * (1 - IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimU')));

mun_prod_area(codmun_ibge_all)$ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') ..
         sum(simucont_id_all$valid_dist_pairs(codmun_ibge_all, simucont_id_all), x(codmun_ibge_all, simucont_id_all)) =E=
                                                                                 ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total');

avail_area(simucont_id_all) ..
         sum(codmun_ibge_all$valid_dist_pairs(codmun_ibge_all, simucont_id_all), x(codmun_ibge_all, simucont_id_all)) =L= CropPastureVegIBGE(simucont_id_all);

min_allocation_per_simu(simucont_id_all)$adjusted_area_to_allocate_into_simu(simucont_id_all) ..
         sum(codmun_ibge_all$valid_dist_pairs(codmun_ibge_all, simucont_id_all), x(codmun_ibge_all, simucont_id_all)) =G= adjusted_area_to_allocate_into_simu(simucont_id_all);

total_allocated_area ..
         sum((codmun_ibge_all, simucont_id_all)$valid_dist_pairs(codmun_ibge_all, simucont_id_all), x(codmun_ibge_all, simucont_id_all)) =L= total_crop_past_ibge_check;

min_allocation_mun_into_simu(codmun_ibge_all, simucont_id_all)$min_allocation_into_simu(codmun_ibge_all, simucont_id_all) ..
         x(codmun_ibge_all, simucont_id_all) =G= min_allocation_into_simu(codmun_ibge_all, simucont_id_all);

MODEL MinimumDistance /ALL/;

*MinimumDistance.iterlim = 0;

*$ontext
SOLVE MinimumDistance USING LP MINIMIZING z;

*---------------------------------------------------------------------------------------------------------------
*--------- number of assigned pairs municipalities and simus
*---------------------------------------------------------------------------------------------------------------

parameter assigned_pairs(codmun_ibge_all, simucont_id_all);
assigned_pairs(codmun_ibge_all, simucont_id_all)$(x.l(codmun_ibge_all, simucont_id_all) > 0) = x.l(codmun_ibge_all, simucont_id_all);

scalar number_assigned_pairs;
number_assigned_pairs = card(assigned_pairs);
display number_assigned_pairs;

*---------------------------------------------------------------------------------------------------------------
*----- checando simus sem alocação, mas que poderiam ter alocação
*---------------------------------------------------------------------------------------------------------------

parameter area_simus_elegiveis(simucont_id_all);
area_simus_elegiveis(simucont_id_all)$(((sum(codmun_ibge_all$(ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') > 0),
                                         IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMunSemAreasProt')) > 0))) =
                                         CropPastureVegIBGE(simucont_id_all);
*display area_simus_elegiveis;

scalar num_area_simus_elegiveis;
num_area_simus_elegiveis = card(area_simus_elegiveis);
display num_area_simus_elegiveis;

scalar num_area_simus_elegiveis_min_alloc;
num_area_simus_elegiveis_min_alloc = card(adjusted_area_to_allocate_into_simu);
display num_area_simus_elegiveis_min_alloc;

parameter areas_simus_com_alloc_from_mun(simucont_id_all);
areas_simus_com_alloc_from_mun(simucont_id_all) = sum(codmun_ibge_all, x.l(codmun_ibge_all, simucont_id_all));

parameter simus_sem_alocacao(simucont_id_all);
simus_sem_alocacao(simucont_id_all)$((adjusted_area_to_allocate_into_simu(simucont_id_all) >= 0) and
                                 (areas_simus_com_alloc_from_mun(simucont_id_all) <= 0)) = adjusted_area_to_allocate_into_simu(simucont_id_all);
*display simus_sem_alocacao;

scalar num_area_simus_com_alloc_from_mun;
num_area_simus_com_alloc_from_mun = card(areas_simus_com_alloc_from_mun);
display num_area_simus_com_alloc_from_mun;

parameter area_simus_without_allocation(simucont_id_all);
area_simus_without_allocation(simucont_id_all)$((sum(codmun_ibge_all, x.l(codmun_ibge_all, simucont_id_all)) <= 0) and
                                       ((sum(codmun_ibge_all$(ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') > 0),
                                         IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMunSemAreasProt')) > 0))) =
                                         CropPastureVegIBGE(simucont_id_all);
*display area_simus_without_allocation;

scalar num_area_simus_without_allocation;
num_area_simus_without_allocation = card(area_simus_without_allocation);
display num_area_simus_without_allocation;

parameter area_simus_with_allocation(simucont_id_all);
area_simus_with_allocation(simucont_id_all)$((sum(codmun_ibge_all, x.l(codmun_ibge_all, simucont_id_all)) > 0) and
                                       ((sum(codmun_ibge_all$(ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') > 0),
                                         IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMunSemAreasProt')) > 0))) =
                                         CropPastureVegIBGE(simucont_id_all);
*display area_simus_with_allocation;

scalar num_area_simus_with_allocation;
num_area_simus_with_allocation = card(area_simus_with_allocation);
display num_area_simus_with_allocation;

*---------------------------------------------------------------------------------------------------------------
*--------- saving solution
*---------------------------------------------------------------------------------------------------------------

file SOLUTION /'.\Resultados\solution_for_distance_minimization.gms'/;

SOLUTION.lw = 0;
SOLUTION.lj = 10;
SOLUTION.nw = 15;
SOLUTION.nd = 3;
SOLUTION.pw = 400;

PUT  SOLUTION;

PUT "PARAMETER SOLUTION_MINIMIZATION(codmun_ibge_all, simucont_id_all) Solution for distance minimization problem for municipality data allocation into SIMUs" /;
PUT "/" /;
LOOP((codmun_ibge_all,simucont_id_all)$x.l(codmun_ibge_all, simucont_id_all),
                 PUT @4 , codmun_ibge_all.tl,'.',simucont_id_all.tl @50;
                 PUT x.l(codmun_ibge_all, simucont_id_all):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*---------------------------------------------------------------------------------------------------------------
*-------- saving solution naive allocation based on simple shares
*---------------------------------------------------------------------------------------------------------------

file SOLUTION2 /'.\Resultados\naive_allocation_results.gms'/;

SOLUTION2.lw = 0;
SOLUTION2.lj = 10;
SOLUTION2.nw = 15;
SOLUTION2.nd = 3;
SOLUTION2.pw = 400;

PUT  SOLUTION2;

PUT "PARAMETER NAIVE_ALLOCATION_X(codmun_ibge_all, simucont_id_all) Nave solution to allocate municipality data into SIMUs" /;
PUT "/" /;
LOOP((codmun_ibge_all,simucont_id_all)$naive_allocation_x(codmun_ibge_all, simucont_id_all),
                 PUT @4 , codmun_ibge_all.tl,'.',simucont_id_all.tl @50;
                 PUT naive_allocation_x(codmun_ibge_all, simucont_id_all):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*---------------------------------------------------------------------------------------------------------------
*-------- saving minimum allocation based on simple shares --------*;
*---------------------------------------------------------------------------------------------------------------

file SOLUTION3 /'.\Resultados\minimum_smooth_allocation.gms'/;

SOLUTION3.lw = 0;
SOLUTION3.lj = 10;
SOLUTION3.nw = 15;
SOLUTION3.nd = 3;
SOLUTION3.pw = 400;

PUT  SOLUTION3;

PUT "PARAMETER MINIMUM_SMOOTH_ALLOCATION(codmun_ibge_all, simucont_id_all) Minimum values to smoothly allocate municipality data into SIMUs" /;
PUT "/" /;
LOOP((codmun_ibge_all,simucont_id_all)$min_allocation_into_simu(codmun_ibge_all, simucont_id_all),
                 PUT @4 , codmun_ibge_all.tl,'.',simucont_id_all.tl @50;
                 PUT min_allocation_into_simu(codmun_ibge_all, simucont_id_all):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*---------------------------------------------------------------------------------------------------------------
*-------- saving upper limites of allocation per simu --------*;
*---------------------------------------------------------------------------------------------------------------

file SOLUTION4 /'.\Resultados\max_possible_allocated_area_to_simu.gms'/;

SOLUTION4.lw = 0;
SOLUTION4.lj = 10;
SOLUTION4.nw = 15;
SOLUTION4.nd = 3;
SOLUTION4.pw = 400;

PUT  SOLUTION4;

PUT "PARAMETER MAX_POSSIBLE_ALLOC_AREA_TO_SIMU(simucont_id_all) Maximum area to be allocated to SIMU" /;
PUT "/" /;
LOOP(simucont_id_all$CropPastureVegIBGE(simucont_id_all),
                 PUT @4 , simucont_id_all.tl @40;
                 PUT CropPastureVegIBGE(simucont_id_all):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*---------------------------------------------------------------------------------------------------------------
*--------- checking the results
*---------------------------------------------------------------------------------------------------------------

PARAMETER Chk_results_mun(codmun_ibge_all);

Chk_results_mun(codmun_ibge_all)
         $(ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') ne
           sum(simucont_id_all, x.l(codmun_ibge_all, simucont_id_all))) =
                 ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') -
                 sum(simucont_id_all, x.l(codmun_ibge_all, simucont_id_all));

display Chk_results_mun;

PARAMETER Chk_results_simu(simucont_id_all);
PARAMETER area_into_simu(simucont_id_all);

area_into_simu(simucont_id_all)
         $(CropPastureVegIBGE_Original(simucont_id_all) <
           sum(codmun_ibge_all$valid_dist_pairs(codmun_ibge_all, simucont_id_all), x.l(codmun_ibge_all, simucont_id_all))) =
                 sum(codmun_ibge_all$valid_dist_pairs(codmun_ibge_all, simucont_id_all), x.l(codmun_ibge_all, simucont_id_all));

Chk_results_simu(simucont_id_all)
         $(CropPastureVegIBGE_Original(simucont_id_all) <
           sum(codmun_ibge_all$valid_dist_pairs(codmun_ibge_all, simucont_id_all), x.l(codmun_ibge_all, simucont_id_all))) =
                 sum(codmun_ibge_all$valid_dist_pairs(codmun_ibge_all, simucont_id_all), x.l(codmun_ibge_all, simucont_id_all)) -
                 CropPastureVegIBGE_Original(simucont_id_all);

display Chk_results_simu;
display area_into_simu;

scalar total_ibge_area_input;
total_ibge_area_input = sum(codmun_ibge_all, ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total'));
display total_ibge_area_input;

scalar total_ibge_area_x;
total_ibge_area_x = sum((codmun_ibge_all, simucont_id_all), x.l(codmun_ibge_all, simucont_id_all));
display total_ibge_area_x;

scalar total_ibge_area_x_valid;
total_ibge_area_x_valid = sum((codmun_ibge_all, simucont_id_all)$valid_dist_pairs(codmun_ibge_all, simucont_id_all), x.l(codmun_ibge_all, simucont_id_all));
display total_ibge_area_x_valid;

scalar excess_area_into_simu;
excess_area_into_simu = sum(simucont_id_all, Chk_results_simu(simucont_id_all));
display excess_area_into_simu;

*---------------------------------------------------------------------------------------------------------------
*----- alocação para simu's que não intersectam com os municípios e que intersectam com os municipios;
*---------------------------------------------------------------------------------------------------------------

parameter x_without_intersection(codmun_ibge_all, simucont_id_all);
x_without_intersection(codmun_ibge_all, simucont_id_all)$(x.l(codmun_ibge_all, simucont_id_all) > 0 and
                                                 (IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMun') <= 0 and
                                                  IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimU') <= 0))
                                                  = x.l(codmun_ibge_all, simucont_id_all);

parameter x_with_intersection(codmun_ibge_all, simucont_id_all);
x_with_intersection(codmun_ibge_all, simucont_id_all)$(x.l(codmun_ibge_all, simucont_id_all) > 0 and
                                                 (IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMun') > 0 or
                                                  IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimU') > 0))
                                                  = x.l(codmun_ibge_all, simucont_id_all);

scalar soma_x_with_intersection;
soma_x_with_intersection = sum((codmun_ibge_all, simucont_id_all), x_with_intersection(codmun_ibge_all, simucont_id_all));
display soma_x_with_intersection;

scalar soma_x_without_intersection;
soma_x_without_intersection = sum((codmun_ibge_all, simucont_id_all), x_without_intersection(codmun_ibge_all, simucont_id_all));
display soma_x_without_intersection;

scalar soma_x_total_inter_no_inter;
soma_x_total_inter_no_inter = soma_x_with_intersection + soma_x_without_intersection;
display soma_x_total_inter_no_inter;

scalar soma_x_check_inter_no_inter;
soma_x_check_inter_no_inter = sum((codmun_ibge_all, simucont_id_all), x.l(codmun_ibge_all, simucont_id_all));
display soma_x_check_inter_no_inter;

scalar razao_x_without_inter;
razao_x_without_inter = soma_x_without_intersection / soma_x_total_inter_no_inter;
display razao_x_without_inter;

*---------------------------------------------------------------------------------------------------------------
*----- salvando as áreas alocadas para as SIMU's (considerando as alocações além do limite)
*---------------------------------------------------------------------------------------------------------------

parameter area_alocada_to_simu(simucont_id_all);
area_alocada_to_simu(simucont_id_all)
         $(sum(codmun_ibge_all$valid_dist_pairs(codmun_ibge_all, simucont_id_all), x.l(codmun_ibge_all, simucont_id_all)) > 0) =
                 sum(codmun_ibge_all$valid_dist_pairs(codmun_ibge_all, simucont_id_all), x.l(codmun_ibge_all, simucont_id_all));

file SOLUTION1 /'.\Resultados\total_allocated_area_to_simu.gms'/;

SOLUTION.lw = 0;
SOLUTION.lj = 10;
SOLUTION.nw = 15;
SOLUTION.nd = 3;
SOLUTION.pw = 400;

PUT  SOLUTION1;

PUT "PARAMETER allocated_area_to_simu(simucont_id_all) Area allocated to SIMU considering allocation beyond the limit" /;
PUT "/" /;
LOOP(simucont_id_all$area_alocada_to_simu(simucont_id_all),
                 PUT @4 , simucont_id_all.tl @40;
                 PUT area_alocada_to_simu(simucont_id_all):30:8 @70;
                 PUT CropPastureVegIBGE_Original(simucont_id_all):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*---------------------------------------------------------------------------------------------------------------
*-------- saving allocation pairs with intersecting areas (simu, municipality) --------*;
*---------------------------------------------------------------------------------------------------------------

file SOLUTION5 /'.\Resultados\allocation_with_intersection.gms'/;

SOLUTION5.lw = 0;
SOLUTION5.lj = 10;
SOLUTION5.nw = 15;
SOLUTION5.nd = 3;
SOLUTION5.pw = 400;

PUT  SOLUTION5;

PUT "PARAMETER X_ALLOC_WITH_INTERSECTION(codmun_ibge_all, simucont_id_all) Allocation of municipality into simu's when there's intersection" /;
PUT "/" /;
LOOP((codmun_ibge_all,simucont_id_all)$x_with_intersection(codmun_ibge_all, simucont_id_all),
                 PUT @4 , codmun_ibge_all.tl,'.',simucont_id_all.tl @50;
                 PUT x_with_intersection(codmun_ibge_all, simucont_id_all):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*---------------------------------------------------------------------------------------------------------------
*-------- saving allocation pairs without intersecting areas (simu, municipality) --------*;
*---------------------------------------------------------------------------------------------------------------

file SOLUTION6 /'.\Resultados\allocation_without_intersection.gms'/;

SOLUTION6.lw = 0;
SOLUTION6.lj = 10;
SOLUTION6.nw = 15;
SOLUTION6.nd = 3;
SOLUTION6.pw = 400;

PUT  SOLUTION6;

PUT "PARAMETER X_ALLOC_WITHOUT_INTERSECTION(codmun_ibge_all, simucont_id_all) Allocation of municipality into simu's when there's no intersection" /;
PUT "/" /;
LOOP((codmun_ibge_all,simucont_id_all)$x_without_intersection(codmun_ibge_all, simucont_id_all),
                 PUT @4 , codmun_ibge_all.tl,'.',simucont_id_all.tl @50;
                 PUT x_without_intersection(codmun_ibge_all, simucont_id_all):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

$onlisting

$ontext
$offtext

*---------------------------------------------------------------------------------------------------------------
*---------                                 the end                                                --------------
*---------------------------------------------------------------------------------------------------------------


