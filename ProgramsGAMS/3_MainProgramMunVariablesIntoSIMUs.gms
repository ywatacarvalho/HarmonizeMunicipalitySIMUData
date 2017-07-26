
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

$include .\Resultados\solution_for_distance_minimization.gms

$include .\Scripts\CheckingCorrecting_inputs_for_simus_allocation.gms

*---------------------------------------------------------------------------------
*--------- checking overall numbers
*---------------------------------------------------------------------------------

parameter area_total_in_municipality(codmun_ibge_all);
area_total_in_municipality(codmun_ibge_all) = sum(simucont_id_all, solution_minimization(codmun_ibge_all, simucont_id_all));

scalar chk_total_area_simus;
chk_total_area_simus = sum((codmun_ibge_all, simucont_id_all), solution_minimization(codmun_ibge_all, simucont_id_all));
display chk_total_area_simus;

parameter share_mun_into_simu(codmun_ibge_all, simucont_id_all);
share_mun_into_simu(codmun_ibge_all, simucont_id_all)$solution_minimization(codmun_ibge_all, simucont_id_all) = solution_minimization(codmun_ibge_all, simucont_id_all) /
                                                                                              area_total_in_municipality(codmun_ibge_all);

parameter chk_shares_mun_into_simu(codmun_ibge_all);
chk_shares_mun_into_simu(codmun_ibge_all) = sum(simucont_id_all, share_mun_into_simu(codmun_ibge_all, simucont_id_all));
display chk_shares_mun_into_simu;

*---------------------------------------------------------------------------------
*--------- planted forest into SIMUs
*---------------------------------------------------------------------------------

PARAMETER ibge_mun_data_planted_forests_by_simu(simucont_id_all, AllVarsMun);

loop(simucont_id_all,
         ibge_mun_data_planted_forests_by_simu(simucont_id_all, AllVarsMun) = sum(codmun_ibge_all, ibge_mun_data_planted_forests(codmun_ibge_all, AllVarsMun)
                                                                         * share_mun_into_simu(codmun_ibge_all, simucont_id_all));
)

parameter chk_total_forests_simu(AllVarsMun);
chk_total_forests_simu(AllVarsMun) = sum(simucont_id_all, ibge_mun_data_planted_forests_by_simu(simucont_id_all, AllVarsMun));
display chk_total_forests_simu;

parameter chk_total_forests_mun(AllVarsMun);
chk_total_forests_mun(AllVarsMun) = sum(codmun_ibge_all, ibge_mun_data_planted_forests(codmun_ibge_all, AllVarsMun));
display chk_total_forests_mun;

*---------------------------------------------------------------------------------
*--------- crops (permanent and temporary) into SIMUs
*---------------------------------------------------------------------------------

PARAMETER ibge_mun_data_crops_by_simu(simucont_id_all, AllVarsMun);

loop(simucont_id_all,
         ibge_mun_data_crops_by_simu(simucont_id_all, AllVarsMun) = sum(codmun_ibge_all, ibge_mun_data_crops(codmun_ibge_all, AllVarsMun)
                                                                         * share_mun_into_simu(codmun_ibge_all, simucont_id_all));
)

parameter chk_total_crops_simu(AllVarsMun);
chk_total_crops_simu(AllVarsMun) = sum(simucont_id_all, ibge_mun_data_crops_by_simu(simucont_id_all, AllVarsMun));
display chk_total_crops_simu;

parameter chk_total_crops_mun(AllVarsMun);
chk_total_crops_mun(AllVarsMun) = sum(codmun_ibge_all, ibge_mun_data_crops(codmun_ibge_all, AllVarsMun));
display chk_total_crops_mun;

*---------------------------------------------------------------------------------
*--------- animals and pasture into SIMUs
*---------------------------------------------------------------------------------

PARAMETER ibge_mun_data_animals_pasture_by_simu(simucont_id_all, AllVarsMun);

loop(simucont_id_all,
         ibge_mun_data_animals_pasture_by_simu(simucont_id_all, AllVarsMun) = sum(codmun_ibge_all, ibge_mun_data_animals_pasture(codmun_ibge_all, AllVarsMun)
                                                                         * share_mun_into_simu(codmun_ibge_all, simucont_id_all));
)

parameter chk_total_animals_pasture_simu(AllVarsMun);
chk_total_animals_pasture_simu(AllVarsMun) = sum(simucont_id_all, ibge_mun_data_animals_pasture_by_simu(simucont_id_all, AllVarsMun));
display chk_total_animals_pasture_simu;

parameter chk_total_animals_pasture_mun(AllVarsMun);
chk_total_animals_pasture_mun(AllVarsMun) = sum(codmun_ibge_all, ibge_mun_data_animals_pasture(codmun_ibge_all, AllVarsMun));
display chk_total_animals_pasture_mun;

*---------------------------------------------------------------------*
*--------- saving shares from municipalities into SIMUS --------------*
*---------------------------------------------------------------------*

file SOLUTION /'.\Resultados\solution_shares_municipalities_into_simus.gms'/;

SOLUTION.lw = 0;
SOLUTION.lj = 10;
SOLUTION.nw = 15;
SOLUTION.nd = 3;
SOLUTION.pw = 400;

PUT  SOLUTION;

PUT "PARAMETER SHARE_MUNS_INTO_SIMUS(codmun_ibge_all, simucont_id_all)" /;
PUT "/" /;
LOOP((codmun_ibge_all,simucont_id_all)$share_mun_into_simu(codmun_ibge_all, simucont_id_all),
                 PUT @4 , codmun_ibge_all.tl,'.',simucont_id_all.tl @50;
                 PUT share_mun_into_simu(codmun_ibge_all, simucont_id_all):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*---------------------------------------------------------------------*
*--------- saving planted forest into SIMUS             --------------*
*---------------------------------------------------------------------*

file SOLUTION1 /'.\Resultados\IBGE_municipality_data_planted_forests_into_simus.gms'/;

SOLUTION.lw = 0;
SOLUTION.lj = 10;
SOLUTION.nw = 15;
SOLUTION.nd = 3;
SOLUTION.pw = 400;

PUT  SOLUTION1;

PUT "PARAMETER ibge_mun_data_planted_forests_into_simu(simucont_id_all, AllVarsMun)" /;
PUT "/" /;
LOOP((simucont_id_all,AllVarsMun)$ibge_mun_data_planted_forests_by_simu(simucont_id_all, AllVarsMun),
                 PUT @4 , simucont_id_all.tl,'.',AllVarsMun.tl:<60 @80;
                 PUT ibge_mun_data_planted_forests_by_simu(simucont_id_all, AllVarsMun):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*---------------------------------------------------------------------*
*--------- saving crops (permanent and temporary) into SIMUS ---------*
*---------------------------------------------------------------------*

file SOLUTION2 /'.\Resultados\IBGE_municipality_data_crops_into_simus.gms'/;

SOLUTION.lw = 0;
SOLUTION.lj = 10;
SOLUTION.nw = 15;
SOLUTION.nd = 3;
SOLUTION.pw = 400;

PUT  SOLUTION2;

PUT "PARAMETER ibge_mun_data_crops_into_simu(simucont_id_all, AllVarsMun)" /;
PUT "/" /;
LOOP((simucont_id_all,AllVarsMun)$ibge_mun_data_crops_by_simu(simucont_id_all, AllVarsMun),
                 PUT @4 , simucont_id_all.tl,'.',AllVarsMun.tl:<60 @80;
                 PUT ibge_mun_data_crops_by_simu(simucont_id_all, AllVarsMun):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*---------------------------------------------------------------------*
*--------- saving animals and pasture into SIMUS             ---------*
*---------------------------------------------------------------------*

file SOLUTION3 /'.\Resultados\IBGE_municipality_data_animals_pasture_into_simus.gms'/;

SOLUTION.lw = 0;
SOLUTION.lj = 10;
SOLUTION.nw = 15;
SOLUTION.nd = 3;
SOLUTION.pw = 400;

PUT  SOLUTION3;

PUT "PARAMETER ibge_mun_data_animals_pasture_into_simu(simucont_id_all, AllVarsMun)" /;
PUT "/" /;
LOOP((simucont_id_all,AllVarsMun)$ibge_mun_data_animals_pasture_by_simu(simucont_id_all, AllVarsMun),
                 PUT @4 , simucont_id_all.tl,'.',AllVarsMun.tl:<60 @80;
                 PUT ibge_mun_data_animals_pasture_by_simu(simucont_id_all, AllVarsMun):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*----------------------------------------------------------------------------------------------------------------*
*---------                                            the end                                      --------------*
*----------------------------------------------------------------------------------------------------------------*
