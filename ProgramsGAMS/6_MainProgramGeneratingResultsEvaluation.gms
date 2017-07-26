
$include .\Scripts\decl_sets_municipalities.gms
$include .\Scripts\decl_sets_SIMUS.gms
$include .\Scripts\decl_sets_SIMUS_contiguas.gms
$include .\Dados\MapSimusContiguasToSimus.gms
$include .\Scripts\decl_sets_others.gms
$include .\Dados\crossMunSimUDisj_to_GAMS.gms
$include .\Dados\IBGE_municipality_data_animals_pasture.gms
$include .\Dados\IBGE_municipality_data_crops.gms
$include .\Dados\IBGE_municipality_data_planted_forests.gms
$include .\Dados\Centroides_Municipalities_5564.gms
$include .\Dados\Centroides_SIMUS_disjuntas.gms
$include .\Dados\LandCoverMapIBGEVegSOSMAProtectedAreas.gms
$include .\Dados\MasksLegalAmazonSimusCont.gms
$include .\Dados\MasksBiomesSimusCont.gms
$include .\Dados\MapMunicipalitiesInLegalAmazon.gms
$include .\Dados\SetSimuidBiomes.gms
$include .\Dados\SetSimuidContiguosBiomes.gms

$include .\Resultados\IBGE_municipality_data_planted_forests_into_simus.gms
$include .\Resultados\IBGE_municipality_data_animals_pasture_into_simus.gms
$include .\Resultados\IBGE_municipality_data_crops_into_simus.gms

$include .\Scripts\CheckingCorrecting_inputs_for_simus_allocation.gms

*----- checking uploaded data

$include .\Resultados\LUC_INIT_MAP_BRAZIL_AREA_CROPS_INTO_SIMUS.gms
$include .\Resultados\LUC_INIT_MAP_BRAZIL_AREA_LC_INTO_SIMUS.gms
$include .\Resultados\LUC_INIT_MAP_BRAZIL_AREA_PLT_FOREST_INTO_SIMUS.gms
$include .\Resultados\LUC_INIT_ALL_PAS_INTO_CLASSES_BY_SIMU.gms
$include .\Resultados\LUC_INIT_MAP_BRAZIL_TLUS_INTO_SIMUS.gms

$include .\Resultados\minimum_smooth_allocation.gms
$include .\Resultados\max_possible_allocated_area_to_simu.gms
$include .\Resultados\naive_allocation_results.gms
$include .\Resultados\allocation_with_intersection.gms
$include .\Resultados\allocation_without_intersection.gms
$include .\Resultados\solution_for_distance_minimization.gms

parameter chk_sum_tlus(AllVarsMun);
chk_sum_tlus(AllVarsMun) = sum(simucont_id_all, TOTAL_ANIMAL_TLUS_PER_SIMU(simucont_id_all, AllVarsMun));
display chk_sum_tlus;

parameter chk_sum_crops(ibgeCROPS);
chk_sum_crops(ibgeCROPS) = sum((simucont_id_all, MngSystem), LUC_INIT_MAP_BRAZIL_AREA_CROPS_SIMUS(simucont_id_all, ibgeCROPS, MngSystem));
display chk_sum_crops;

scalar chk_sum_classes;
chk_sum_classes = sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, 'CrpLnd')) +
                         sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, 'OthAgri')) +
                         sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, 'Grass')) +
                         sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, 'Forest')) +
                         sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, 'WetLnd')) +
                         sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, 'OthNatLnd')) +
                         sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, 'NotRel')) +
                         sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, 'PAs'));
display chk_sum_classes;

scalar chk_sum_plt_forest;
chk_sum_plt_forest = sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_PLT_FOREST_SIMUS(simucont_id_all));
display chk_sum_plt_forest;

parameter chk_sum_land_cover_pas(GlobiomClassesFromVegIbge);
chk_sum_land_cover_pas(GlobiomClassesFromVegIbge) = sum(simucont_id_all, LAND_COVER_PAS_INTO_CLASSES_BY_SIMU(simucont_id_all, GlobiomClassesFromVegIbge));
display chk_sum_land_cover_pas;

scalar chk_sum_land_cover_pas_into_classes;
chk_sum_land_cover_pas_into_classes = sum((simucont_id_all, GlobiomClassesFromVegIbge), LAND_COVER_PAS_INTO_CLASSES_BY_SIMU(simucont_id_all, GlobiomClassesFromVegIbge));
display chk_sum_land_cover_pas_into_classes;

scalar chk_othnatlnd_com_pas;
chk_othnatlnd_com_pas = sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, 'OthNatLnd'))
                        +  sum(simucont_id_all, LAND_COVER_PAS_INTO_CLASSES_BY_SIMU(simucont_id_all, 'OTHER_NATURAL_LAND'));
display chk_othnatlnd_com_pas;

parameter legal_am(simucont_id_all);
legal_am(simucont_id_all) = LegalAmazonBiomeMap(simucont_id_all);
scalar num_legal_am;
num_legal_am = card(legal_am);
display num_legal_am;

parameter non_legal_am(simucont_id_all);
non_legal_am(simucont_id_all) = 1 - legal_am(simucont_id_all);
scalar num_non_legal_am;
num_non_legal_am = card(non_legal_am);
display num_non_legal_am;

scalar numero_map_amazonlegal;
numero_map_amazonlegal = card(LegalAmazonBiomeMap);
display numero_map_amazonlegal;

*---------------------------------------------------------------;
*-------- preparing statistics to present on the paper  --------;
*---------------------------------------------------------------;

parameter LUC_INIT_MAP_BRAZIL_AREA_CROPS_BIOMES(Biome);
parameter LUC_INIT_MAP_BRAZIL_AREA_LC_BIOMES(Biome, LC_TYPES_BRAZIL);
parameter LAND_COVER_PAS_INTO_CLASSES_BY_BIOMES(Biome, GlobiomClassesFromVegIbge);
parameter LAND_COVER_IBGE_VEG_MAP_BIOMES(Biome, VegIbgeMapVars, GlobiomClassesFromVegIbge);

parameter LUC_INIT_MAP_BRAZIL_AREA_LC_LEGAL_AM(LC_TYPES_BRAZIL);
parameter LAND_COVER_PAS_INTO_CLASSES_BY_LEGAL_AM(GlobiomClassesFromVegIbge);
parameter LAND_COVER_IBGE_VEG_MAP_LEGAL_AM(VegIbgeMapVars, GlobiomClassesFromVegIbge);
scalar SUM_LAND_COVER_PAS_INTO_CLASSES_BY_LEGAL_AM;

LUC_INIT_MAP_BRAZIL_AREA_CROPS_BIOMES(Biome) = sum((simucont_id_all, MngSystem, ibgeCROPS), LUC_INIT_MAP_BRAZIL_AREA_CROPS_SIMUS(simucont_id_all, ibgeCROPS, MngSystem)*SimuidContiguoBiome(simucont_id_all, Biome));
LUC_INIT_MAP_BRAZIL_AREA_LC_BIOMES(Biome, LC_TYPES_BRAZIL) = sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, LC_TYPES_BRAZIL)*SimuidContiguoBiome(simucont_id_all, Biome));
LAND_COVER_PAS_INTO_CLASSES_BY_BIOMES(Biome, GlobiomClassesFromVegIbge) = sum(simucont_id_all, LAND_COVER_PAS_INTO_CLASSES_BY_SIMU(simucont_id_all, GlobiomClassesFromVegIbge)*SimuidContiguoBiome(simucont_id_all, Biome));
LAND_COVER_IBGE_VEG_MAP_BIOMES(Biome, VegIbgeMapVars, GlobiomClassesFromVegIbge) = sum(simucont_id_all, LAND_COVER_IBGE_VEG_MAP(simucont_id_all, GlobiomClassesFromVegIbge, VegIbgeMapVars)*SimuidContiguoBiome(simucont_id_all, Biome));

LUC_INIT_MAP_BRAZIL_AREA_LC_LEGAL_AM(LC_TYPES_BRAZIL) = sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, LC_TYPES_BRAZIL)*legal_am(simucont_id_all));
LAND_COVER_PAS_INTO_CLASSES_BY_LEGAL_AM(GlobiomClassesFromVegIbge) = sum(simucont_id_all, LAND_COVER_PAS_INTO_CLASSES_BY_SIMU(simucont_id_all, GlobiomClassesFromVegIbge)*legal_am(simucont_id_all));
LAND_COVER_IBGE_VEG_MAP_LEGAL_AM(VegIbgeMapVars, GlobiomClassesFromVegIbge) = sum(simucont_id_all, LAND_COVER_IBGE_VEG_MAP(simucont_id_all, GlobiomClassesFromVegIbge, VegIbgeMapVars)*legal_am(simucont_id_all));
SUM_LAND_COVER_PAS_INTO_CLASSES_BY_LEGAL_AM = sum(GlobiomClassesFromVegIbge, LAND_COVER_PAS_INTO_CLASSES_BY_LEGAL_AM(GlobiomClassesFromVegIbge));

display LUC_INIT_MAP_BRAZIL_AREA_CROPS_BIOMES;
display LUC_INIT_MAP_BRAZIL_AREA_LC_BIOMES;
display LAND_COVER_PAS_INTO_CLASSES_BY_BIOMES;
display LAND_COVER_IBGE_VEG_MAP_BIOMES;

display LUC_INIT_MAP_BRAZIL_AREA_LC_LEGAL_AM;
display LAND_COVER_PAS_INTO_CLASSES_BY_LEGAL_AM;
display LAND_COVER_IBGE_VEG_MAP_LEGAL_AM;
display SUM_LAND_COVER_PAS_INTO_CLASSES_BY_LEGAL_AM;

*---------------------------------------------------;
*-------- saving the results in a CSV files --------;
*---------------------------------------------------;

file SOLUTION2 /'.\Resultados\LUC_INIT_MAP_BRAZIL_AREA_LC_INTO_SIMUS.csv'/;

SOLUTION2.lw = 0;
SOLUTION2.lj = 10;
SOLUTION2.nw = 15;
SOLUTION2.nd = 3;
SOLUTION2.pw = 400;

PUT  SOLUTION2;

PUT "simucont_id_all, LC_TYPES_BRAZIL, area_Mha" /;
LOOP((simucont_id_all,LC_TYPES_BRAZIL)$(LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, LC_TYPES_BRAZIL) > 0),
                 PUT @4 , simucont_id_all.tl,',',LC_TYPES_BRAZIL.tl,',', LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, LC_TYPES_BRAZIL):30:8
                 PUT /;
)

PUTCLOSE;

*----------------------------------------------------------------------------*;
*------- saving indicators to evaluate algorithm results               ------*;
*----------------------------------------------------------------------------*;

parameter area_total_simucont_id_all(simucont_id_all);
area_total_simucont_id_all(simucont_id_all) = sum(GlobiomClassesFromVegIbge, LAND_COVER_IBGE_VEG_MAP(simucont_id_all, GlobiomClassesFromVegIbge, 'area_veg_ibge_sosma_simu'));

parameter areas_muns(codmun_ibge_all);
areas_muns(codmun_ibge_all) = sum(simucont_id_all, IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMun')*area_total_simucont_id_all(simucont_id_all));

parameter sum_area_total_simucont_id_all;
sum_area_total_simucont_id_all = sum(simucont_id_all, area_total_simucont_id_all(simucont_id_all));
display sum_area_total_simucont_id_all;

scalar sum_areas_muns;
sum_areas_muns = sum(codmun_ibge_all, areas_muns(codmun_ibge_all));
display sum_areas_muns;

PARAMETER ibge_mun_data(codmun_ibge_all, AllVarsMun) Data for land use and cover analysis (area in thousand ha);

ibge_mun_data(codmun_ibge_all,'all_crops_area_ibge_2000') = (ibge_mun_data_crops(codmun_ibge_all, 'area_ha_2000_CultPermanentes') +
                                                            ibge_mun_data_crops(codmun_ibge_all, 'area_ha_2000_CultTemporarias')) / 1000;

ibge_mun_data(codmun_ibge_all,'area_grass_2000_ibge_total') = ibge_mun_data_animals_pasture(codmun_ibge_all, 'area_ha_2000_pasture') / 1000;

ibge_mun_data(codmun_ibge_all,'area_planted_forest_2006_ibge') = ibge_mun_data_planted_forests(codmun_ibge_all, 'area_ha_2006_ForestPlanted') / 1000;

ibge_mun_data(codmun_ibge_all,'area_crop_pasture_2000_total') = ibge_mun_data(codmun_ibge_all,'all_crops_area_ibge_2000') +
                                                                ibge_mun_data(codmun_ibge_all,'area_grass_2000_ibge_total') +
                                                                ibge_mun_data(codmun_ibge_all,'area_planted_forest_2006_ibge');

scalar sum_areas_crop_past_plfor_muns;
sum_areas_crop_past_plfor_muns = sum(codmun_ibge_all, ibge_mun_data(codmun_ibge_all,'area_crop_pasture_2000_total'));
display sum_areas_crop_past_plfor_muns;

parameter distances(codmun_ibge_all, simucont_id_all);
distances(codmun_ibge_all, simucont_id_all)$(((SOLUTION_MINIMIZATION(codmun_ibge_all, simucont_id_all) > 0) or
                                (MINIMUM_SMOOTH_ALLOCATION(codmun_ibge_all, simucont_id_all) > 0) or
                                (NAIVE_ALLOCATION_X(codmun_ibge_all, simucont_id_all) > 0)))
                                         = sqrt(power(CentroidesSIMU(simucont_id_all, 'X') - CentroidesMun(codmun_ibge_all, 'X'), 2) +
                                                power(CentroidesSIMU(simucont_id_all, 'Y') - CentroidesMun(codmun_ibge_all, 'Y'), 2));

*---- indicadores por municípios;

file SOLUTION1 /'.\Resultados\RESULT_AREAS_POR_MUNICIPIOS.csv'/;

SOLUTION1.lw = 0;
SOLUTION1.lj = 10;
SOLUTION1.nw = 15;
SOLUTION1.nd = 3;
SOLUTION1.pw = 400;

PUT  SOLUTION1;

PUT "codmun_ibge, area_mun_Mha, area_crop_past_plfor_Mha" /;
LOOP(codmun_ibge_all$(((areas_muns(codmun_ibge_all) > 0) or
                       (ibge_mun_data(codmun_ibge_all,'area_crop_pasture_2000_total') > 0))),
                 PUT @4 , codmun_ibge_all.tl,',', areas_muns(codmun_ibge_all):30:8,',',
                                                  ibge_mun_data(codmun_ibge_all,'area_crop_pasture_2000_total'):30:8
                 PUT /;
)

PUTCLOSE;

*--- allocation with intersecting simus and municipalities;

file SOLUTION3 /'.\Resultados\RESULT_X_ALLOC_WITH_INTERSECTION.csv'/;

SOLUTION3.lw = 0;
SOLUTION3.lj = 10;
SOLUTION3.nw = 15;
SOLUTION3.nd = 3;
SOLUTION3.pw = 400;

PUT  SOLUTION3;

PUT "codmun_ibge, simucont_id_all, x_alloc_area_Mha, distance_Euclidian" /;
LOOP((codmun_ibge_all, simucont_id_all)$(X_ALLOC_WITH_INTERSECTION(codmun_ibge_all, simucont_id_all) > 0),
                 PUT @4 , codmun_ibge_all.tl,',', simucont_id_all.tl,',', X_ALLOC_WITH_INTERSECTION(codmun_ibge_all, simucont_id_all):30:8, ',',
                                                                 distances(codmun_ibge_all, simucont_id_all):30:8
                 PUT /;
)

PUTCLOSE;

*--- allocation without intersecting simus and municipalities;

file SOLUTION4 /'.\Resultados\RESULT_X_ALLOC_WITHOUT_INTERSECTION.csv'/;

SOLUTION4.lw = 0;
SOLUTION4.lj = 10;
SOLUTION4.nw = 15;
SOLUTION4.nd = 3;
SOLUTION4.pw = 400;

PUT  SOLUTION4;

PUT "codmun_ibge, simucont_id_all, x_alloc_area_Mha, distance_Euclidian" /;
LOOP((codmun_ibge_all, simucont_id_all)$(X_ALLOC_WITHOUT_INTERSECTION(codmun_ibge_all, simucont_id_all) > 0),
                 PUT @4 , codmun_ibge_all.tl,',', simucont_id_all.tl,',', X_ALLOC_WITHOUT_INTERSECTION(codmun_ibge_all, simucont_id_all):30:8, ',',
                                                                 distances(codmun_ibge_all, simucont_id_all):30:8
                 PUT /;
)

PUTCLOSE;

*---- allocation x(mun, simu) for different situations;

file SOLUTION5 /'.\Resultados\RESULT_X_ALLOC_VARIOUS_SITUATIONS.csv'/;

SOLUTION5.lw = 0;
SOLUTION5.lj = 10;
SOLUTION5.nw = 15;
SOLUTION5.nd = 3;
SOLUTION5.pw = 400;

PUT  SOLUTION5;

PUT "codmun_ibge, simucont_id_all, naive_alloc_Mha, min_alloc_Mha, opt_alloc_Mha, distancia_Euclidiana, shareSimUInMun, shareMunInSimU" /;
LOOP((codmun_ibge_all, simucont_id_all)$(((SOLUTION_MINIMIZATION(codmun_ibge_all, simucont_id_all) > 0) or
                                (MINIMUM_SMOOTH_ALLOCATION(codmun_ibge_all, simucont_id_all) > 0) or
                                (NAIVE_ALLOCATION_X(codmun_ibge_all, simucont_id_all) > 0))),
                 PUT @4 , codmun_ibge_all.tl,',', simucont_id_all.tl,',', NAIVE_ALLOCATION_X(codmun_ibge_all, simucont_id_all):30:8,',',
                                                                 MINIMUM_SMOOTH_ALLOCATION(codmun_ibge_all, simucont_id_all):30:8,',',
                                                                 SOLUTION_MINIMIZATION(codmun_ibge_all, simucont_id_all):30:8,',',
                                                                 distances(codmun_ibge_all, simucont_id_all):30:8,',',
                                                                 IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMun'):30:8,',',
                                                                 IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimU'):30:8
                 PUT /;
)

PUTCLOSE;

*---- total allocation into simu's for different situations;

parameter SOLUTION_MINIMIZATION_SIMU(simucont_id_all);
parameter MINIMUM_SMOOTH_ALLOCATION_SIMU(simucont_id_all);
parameter NAIVE_ALLOCATION_X_SIMU(simucont_id_all);

SOLUTION_MINIMIZATION_SIMU(simucont_id_all) = SUM(codmun_ibge_all, SOLUTION_MINIMIZATION(codmun_ibge_all, simucont_id_all));
MINIMUM_SMOOTH_ALLOCATION_SIMU(simucont_id_all) = SUM(codmun_ibge_all, MINIMUM_SMOOTH_ALLOCATION(codmun_ibge_all, simucont_id_all));
NAIVE_ALLOCATION_X_SIMU(simucont_id_all) = SUM(codmun_ibge_all, NAIVE_ALLOCATION_X(codmun_ibge_all, simucont_id_all));

file SOLUTION6 /'.\Resultados\RESULT_TOTAL_ALLOC_PER_SIMU_VARIOUS_SITUATIONS.csv'/;

SOLUTION6.lw = 0;
SOLUTION6.lj = 10;
SOLUTION6.nw = 15;
SOLUTION6.nd = 3;
SOLUTION6.pw = 400;

PUT  SOLUTION6;

PUT "simucont_id_all, naive_alloc_Mha, min_alloc_Mha, opt_alloc_Mha, max_possible_alloc_Mha" /;
LOOP(simucont_id_all$(((SOLUTION_MINIMIZATION_SIMU(simucont_id_all) > 0) or
              (MINIMUM_SMOOTH_ALLOCATION_SIMU(simucont_id_all) > 0) or
              (MAX_POSSIBLE_ALLOC_AREA_TO_SIMU(simucont_id_all) > 0) or
              (NAIVE_ALLOCATION_X_SIMU(simucont_id_all) > 0))),
                 PUT @4 , simucont_id_all.tl,',', NAIVE_ALLOCATION_X_SIMU(simucont_id_all):30:8,',',
                                         MINIMUM_SMOOTH_ALLOCATION_SIMU(simucont_id_all):30:8,',',
                                         SOLUTION_MINIMIZATION_SIMU(simucont_id_all):30:8,',',
                                         MAX_POSSIBLE_ALLOC_AREA_TO_SIMU(simucont_id_all):30:8
                 PUT /;
)

PUTCLOSE;


$ONTEXT
$OFFTEXT

*-----------------------------------------------------------------------------*
*--------- the end                                              --------------*
*-----------------------------------------------------------------------------*
