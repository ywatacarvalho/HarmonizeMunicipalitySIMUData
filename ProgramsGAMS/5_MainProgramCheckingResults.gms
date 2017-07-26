
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

parameter chk_sum_tlus(AllVarsMun);
chk_sum_tlus(AllVarsMun) = sum(simucont_id_all, TOTAL_ANIMAL_TLUS_PER_SIMU(simucont_id_all, AllVarsMun));
display chk_sum_tlus;

parameter chk_sum_lc_map_brazil(lc_types_brazil);
chk_sum_lc_map_brazil(lc_types_brazil) = sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, LC_TYPES_BRAZIL));
display chk_sum_lc_map_brazil;

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

$ONTEXT
$OFFTEXT

*-----------------------------------------------------------------------------*
*--------- the end                                              --------------*
*-----------------------------------------------------------------------------*
