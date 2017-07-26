
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

*---------------------------------------------------------------------------------
*----- checking uploaded data
*---------------------------------------------------------------------------------

parameter chk_total_forests_simu(AllVarsMun);
chk_total_forests_simu(AllVarsMun) = sum(simucont_id_all, ibge_mun_data_planted_forests_into_simu(simucont_id_all, AllVarsMun));
display chk_total_forests_simu;

parameter chk_total_forests_mun(AllVarsMun);
chk_total_forests_mun(AllVarsMun) = sum(codmun_ibge_all, ibge_mun_data_planted_forests(codmun_ibge_all, AllVarsMun));
display chk_total_forests_mun;

parameter chk_total_crops_simu(AllVarsMun);
chk_total_crops_simu(AllVarsMun) = sum(simucont_id_all, ibge_mun_data_crops_into_simu(simucont_id_all, AllVarsMun));
display chk_total_crops_simu;

parameter chk_total_crops_mun(AllVarsMun);
chk_total_crops_mun(AllVarsMun) = sum(codmun_ibge_all, ibge_mun_data_crops(codmun_ibge_all, AllVarsMun));
display chk_total_crops_mun;

parameter chk_total_animals_pasture_simu(AllVarsMun);
chk_total_animals_pasture_simu(AllVarsMun) = sum(simucont_id_all, ibge_mun_data_animals_pasture_into_simu(simucont_id_all, AllVarsMun));
display chk_total_animals_pasture_simu;

parameter chk_total_animals_pasture_mun(AllVarsMun);
chk_total_animals_pasture_mun(AllVarsMun) = sum(codmun_ibge_all, ibge_mun_data_animals_pasture(codmun_ibge_all, AllVarsMun));
display chk_total_animals_pasture_mun;

*--------------------------------------------------------------------------------------------------
*------ consolidating the other classes of land use and land cover from IBGE vegetation map
*--------------------------------------------------------------------------------------------------

*LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'NOT_RELEVANT_MODIS', 'area_total_simu_veg_ibge') =
*                                 OtherRelated2000ModisIntoSIMUs(simucont_id_all) * 0.001;

*---- adjusting other classes for land use and cover map

LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PASTURE', 'area_total_simu_veg_ibge') =
                                 ibge_mun_data_animals_pasture_into_simu(simucont_id_all, 'area_ha_2000_pasture') * 0.001;

LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP', 'area_total_simu_veg_ibge') =
                                 (ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_CultPermanentes') +
                                  ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_CultTemporarias')) * 0.001;

LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PLANTED_FOREST', 'area_total_simu_veg_ibge') =
                                 ibge_mun_data_planted_forests_into_simu(simucont_id_all, 'area_ha_2006_ForestPlanted') * 0.001;

parameter total_pasture_crop_planted_forest(simucont_id_all);
total_pasture_crop_planted_forest(simucont_id_all) = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PASTURE', 'area_total_simu_veg_ibge') +
                                                     LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP', 'area_total_simu_veg_ibge') +
                                                     LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PLANTED_FOREST', 'area_total_simu_veg_ibge');

scalar sum_total_pasture_crop_planted_forest;
sum_total_pasture_crop_planted_forest = sum(simucont_id_all, total_pasture_crop_planted_forest(simucont_id_all));
display sum_total_pasture_crop_planted_forest;

parameter total_inicial_available_crop_pasture_other_nat_land(simucont_id_all);
total_inicial_available_crop_pasture_other_nat_land(simucont_id_all) =
                                 LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP_PASTURE_OR_OTHER_NATURAL_LAND', 'area_total_simu_veg_ibge') -
                                 LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP_PASTURE_OR_OTHER_NATURAL_LAND', 'area_simu_veg_ibge_all_pas') +
                                 LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND', 'area_total_simu_veg_ibge') -
                                 LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND', 'area_simu_veg_ibge_all_pas');

parameter total_inicial_forest_land(simucont_id_all);
total_inicial_forest_land(simucont_id_all)$(LegalAmazonBiomeMap(simucont_id_all)) =
                                 percentual_allowed_forest * (LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST', 'area_total_simu_veg_ibge') -
                                                              LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST', 'area_simu_veg_ibge_all_pas'));

parameter total_inicial_wetlands(simucont_id_all);
total_inicial_wetlands(simucont_id_all)$(LegalAmazonBiomeMap(simucont_id_all)) =
                                 percentual_allowed_wetlands * (LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS', 'area_total_simu_veg_ibge') -
                                                                LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS', 'area_simu_veg_ibge_all_pas'));

LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND_ADJUSTED', 'area_total_simu_veg_ibge') =
                                         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP_PASTURE_OR_OTHER_NATURAL_LAND', 'area_total_simu_veg_ibge') +
                                         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND', 'area_total_simu_veg_ibge') -
                                         min(total_inicial_available_crop_pasture_other_nat_land(simucont_id_all),
                                             total_pasture_crop_planted_forest(simucont_id_all));
LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND_ADJUSTED', 'area_total_simu_veg_ibge')$
                         (LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND_ADJUSTED', 'area_total_simu_veg_ibge') < 0) = 0

scalar soma_crop_pasture_planted_forest_in_inicial_aval_land;
soma_crop_pasture_planted_forest_in_inicial_aval_land = sum(simucont_id_all,
                                 min(total_inicial_available_crop_pasture_other_nat_land(simucont_id_all),
                                     total_pasture_crop_planted_forest(simucont_id_all)));
display soma_crop_pasture_planted_forest_in_inicial_aval_land;

scalar soma_crop_pasture_planted_forest_in_inicial_forest;
soma_crop_pasture_planted_forest_in_inicial_forest = sum(simucont_id_all, min(total_inicial_forest_land(simucont_id_all),
                                     max(0, total_pasture_crop_planted_forest(simucont_id_all) - total_inicial_available_crop_pasture_other_nat_land(simucont_id_all))));
display soma_crop_pasture_planted_forest_in_inicial_forest;

parameter crop_pasture_planted_forest_in_inicial_forest(simucont_id_all);
crop_pasture_planted_forest_in_inicial_forest(simucont_id_all) = min(total_inicial_forest_land(simucont_id_all),
                                     max(0, total_pasture_crop_planted_forest(simucont_id_all) - total_inicial_available_crop_pasture_other_nat_land(simucont_id_all)));

LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST_NON_PLANTED', 'area_total_simu_veg_ibge') =
                                          LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST', 'area_total_simu_veg_ibge') -
                                          crop_pasture_planted_forest_in_inicial_forest(simucont_id_all);

scalar sum_crop_pasture_planted_forest_in_inicial_forest;
sum_crop_pasture_planted_forest_in_inicial_forest = sum(simucont_id_all, crop_pasture_planted_forest_in_inicial_forest(simucont_id_all));
display sum_crop_pasture_planted_forest_in_inicial_forest;

parameter crop_pasture_planted_forest_in_inicial_avail_land_and_for(simucont_id_all);
crop_pasture_planted_forest_in_inicial_avail_land_and_for(simucont_id_all) = crop_pasture_planted_forest_in_inicial_forest(simucont_id_all) +
                                                                             min(total_inicial_available_crop_pasture_other_nat_land(simucont_id_all),
                                                                                 total_pasture_crop_planted_forest(simucont_id_all));

scalar sum_crop_pasture_planted_forest_in_inicial_avail_land_and_for;
sum_crop_pasture_planted_forest_in_inicial_avail_land_and_for = sum(simucont_id_all, crop_pasture_planted_forest_in_inicial_avail_land_and_for(simucont_id_all));
display sum_crop_pasture_planted_forest_in_inicial_avail_land_and_for;

parameter crop_pasture_planted_forest_in_initial_wetlands(simucont_id_all);
crop_pasture_planted_forest_in_initial_wetlands(simucont_id_all) = total_pasture_crop_planted_forest(simucont_id_all) -
                                                                   crop_pasture_planted_forest_in_inicial_avail_land_and_for(simucont_id_all);

scalar sum_crop_pasture_planted_forest_in_initial_wetlands;
sum_crop_pasture_planted_forest_in_initial_wetlands = sum(simucont_id_all, crop_pasture_planted_forest_in_initial_wetlands(simucont_id_all));
display sum_crop_pasture_planted_forest_in_initial_wetlands;

LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS_ADJUSTED', 'area_total_simu_veg_ibge') =
                                 LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS', 'area_total_simu_veg_ibge') -
                                 crop_pasture_planted_forest_in_initial_wetlands(simucont_id_all);

scalar soma_crop_pasture_planted_forest_in_all_inicial_areas;
soma_crop_pasture_planted_forest_in_all_inicial_areas = soma_crop_pasture_planted_forest_in_inicial_aval_land +
                                                        soma_crop_pasture_planted_forest_in_inicial_forest +
                                                        sum_crop_pasture_planted_forest_in_initial_wetlands;
display soma_crop_pasture_planted_forest_in_all_inicial_areas;

parameter chk_neg_crop_pasture_planted_forest_in_inicial_wetlands(simucont_id_all);
chk_neg_crop_pasture_planted_forest_in_inicial_wetlands(simucont_id_all)$(crop_pasture_planted_forest_in_initial_wetlands(simucont_id_all) < -1e-8) =
                                                                                 crop_pasture_planted_forest_in_initial_wetlands(simucont_id_all);
display chk_neg_crop_pasture_planted_forest_in_inicial_wetlands;

parameter chk_neg_crop_pasture_planted_forest_in_inicial_forest(simucont_id_all);
chk_neg_crop_pasture_planted_forest_in_inicial_forest(simucont_id_all)$(crop_pasture_planted_forest_in_inicial_forest(simucont_id_all) < -1e-8) =
                                                                                 crop_pasture_planted_forest_in_inicial_forest(simucont_id_all);
display chk_neg_crop_pasture_planted_forest_in_inicial_forest;

*------------------------------------------------------------------------------------------
*---- checking the totals from the land use adjusted classes
*------------------------------------------------------------------------------------------

LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'TOTAL_IBGE_VEG_CLASSES', 'area_total_simu_veg_ibge') =
         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP_PASTURE_OR_OTHER_NATURAL_LAND', 'area_total_simu_veg_ibge') +
         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST', 'area_total_simu_veg_ibge') +
         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'NOT_RELEVANT', 'area_total_simu_veg_ibge') +
         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND', 'area_total_simu_veg_ibge') +
         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS', 'area_total_simu_veg_ibge');

LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'TOTAL_DERIVED_CLASSES', 'area_total_simu_veg_ibge') =
         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP', 'area_total_simu_veg_ibge') +
         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST_NON_PLANTED', 'area_total_simu_veg_ibge') +
         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PLANTED_FOREST', 'area_total_simu_veg_ibge') +
         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND_ADJUSTED', 'area_total_simu_veg_ibge') +
         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS_ADJUSTED', 'area_total_simu_veg_ibge') +
         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PASTURE', 'area_total_simu_veg_ibge')+
         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'NOT_RELEVANT', 'area_total_simu_veg_ibge');

parameter sum_area_classes_globiom_veg_ibge(GlobiomClassesFromVegIbge);
sum_area_classes_globiom_veg_ibge(GlobiomClassesFromVegIbge) = sum(simucont_id_all,
                     LAND_COVER_IBGE_VEG_MAP(simucont_id_all, GlobiomClassesFromVegIbge, 'area_total_simu_veg_ibge'));
display sum_area_classes_globiom_veg_ibge;

parameter chk_negative_values_ibge_veg_map(simucont_id_all);
chk_negative_values_ibge_veg_map(simucont_id_all)$((LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP', 'area_total_simu_veg_ibge') < 0) or
                                             (LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST_NON_PLANTED', 'area_total_simu_veg_ibge') < 0) or
                                             (LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PLANTED_FOREST', 'area_total_simu_veg_ibge') < 0) or
                                             (LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND_ADJUSTED', 'area_total_simu_veg_ibge') < 0) or
                                             (LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS', 'area_total_simu_veg_ibge') < 0) or
                                             (LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PASTURE', 'area_total_simu_veg_ibge') < 0) or
                                             (LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'NOT_RELEVANT_ADJUSTED', 'area_total_simu_veg_ibge') < 0)) =
                                    min(0, LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP', 'area_total_simu_veg_ibge')) +
                                             min(0, LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST_NON_PLANTED', 'area_total_simu_veg_ibge')) +
                                             min(0, LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PLANTED_FOREST', 'area_total_simu_veg_ibge')) +
                                             min(0, LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND_ADJUSTED', 'area_total_simu_veg_ibge')) +
                                             min(0, LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS', 'area_total_simu_veg_ibge')) +
                                             min(0, LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PASTURE', 'area_total_simu_veg_ibge')) +
                                             min(0, LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'NOT_RELEVANT_ADJUSTED', 'area_total_simu_veg_ibge'));
display chk_negative_values_ibge_veg_map;

*------------------------------------------------------------------------------------------
*---- creating file to be used in GLOBIOM with crop information
*------------------------------------------------------------------------------------------

PARAMETER LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, ibgeCROPS, MngSystem);

$ONTEXT
ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Aveia');
ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Cacau');
ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Cafe');
ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_CastanhaCaju');
ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Sisal');
$OFFTEXT

LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Barl', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Cevada');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'BeaD', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Feijao');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Cass', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Mandioca');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Corn', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Milho');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Cott', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Algodao');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Gnut', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Amendoim');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Pota', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Batata');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Rice', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Arroz');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Soya', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Soja');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Srgh', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Sorgo');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'SugC', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_CanaDeAcucar');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Sunf', MngSystem) = 0.0;
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'SwPo', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_BatataDoce');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Whea', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Trigo');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'OPAL', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Dende');

LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Barl', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Cevada');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'BeaD', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Feijao');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Cass', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Mandioca');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Corn', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Milho');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Cott', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Algodao');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Gnut', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Amendoim');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Pota', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Batata');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Rice', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Arroz');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Soya', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Soja');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Srgh', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Sorgo');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'SugC', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_CanaDeAcucar');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Sunf', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = 0.0;
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'SwPo', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_BatataDoce');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'Whea', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Trigo');
LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, 'OPAL', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_Dende');

parameter chk_crops_area_negative(simucont_id_all, ibgeCROPS, MngSystem);
chk_crops_area_negative(simucont_id_all, ibgeCROPS, MngSystem)$(LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, ibgeCROPS, MngSystem) < 0) =
                                                         LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, ibgeCROPS, MngSystem);
display chk_crops_area_negative;

*------------------------------------------------------------------------------------------
*---- creating file to be used in GLOBIOM with land cover information
*------------------------------------------------------------------------------------------

PARAMETER LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, LC_TYPES_BRAZIL);

LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd') = sum(ibgeCROPS, LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, ibgeCROPS, 'All'));
LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'OthAgri') = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP', 'area_total_simu_veg_ibge') -
                                                         LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd');
LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'Grass') = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PASTURE', 'area_total_simu_veg_ibge');

LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'Forest') = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PLANTED_FOREST', 'area_total_simu_veg_ibge') +
                                                         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST_NON_PLANTED', 'area_total_simu_veg_ibge') -
                                                         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST', 'area_simu_veg_ibge_all_pas');

*LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'OthNatLnd') = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND_ADJUSTED', 'area_total_simu_veg_ibge') -
*                                                            LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND', 'area_simu_veg_ibge_all_pas') -
*                                                            LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP_PASTURE_OR_OTHER_NATURAL_LAND', 'area_simu_veg_ibge_all_pas');

LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'OthNatLnd') = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND_ADJUSTED', 'area_total_simu_veg_ibge') -
                                                            LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND', 'area_simu_veg_ibge_all_pas') -
                                                            LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP_PASTURE_OR_OTHER_NATURAL_LAND', 'area_simu_veg_ibge_all_pas');

LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'NotRel') = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'NOT_RELEVANT', 'area_total_simu_veg_ibge') -
                                                         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'NOT_RELEVANT', 'area_simu_veg_ibge_all_pas');

LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'WetLnd') = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS_ADJUSTED', 'area_total_simu_veg_ibge') -
                                                         LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS', 'area_simu_veg_ibge_all_pas');

LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'PAs') = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS', 'area_simu_veg_ibge_all_pas') +
                                                      LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'NOT_RELEVANT', 'area_simu_veg_ibge_all_pas') +
                                                      LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND', 'area_simu_veg_ibge_all_pas') +
                                                      LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST', 'area_simu_veg_ibge_all_pas') +
                                                      LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP_PASTURE_OR_OTHER_NATURAL_LAND', 'area_simu_veg_ibge_all_pas');

LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'SimUarea') = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS', 'area_total_simu_veg_ibge') +
                                                           LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'NOT_RELEVANT', 'area_total_simu_veg_ibge') +
                                                           LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND', 'area_total_simu_veg_ibge') +
                                                           LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST', 'area_total_simu_veg_ibge') +
                                                           LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP_PASTURE_OR_OTHER_NATURAL_LAND', 'area_total_simu_veg_ibge');

LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd_H') = ShareMngSystem('HI') * LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd');
LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd_L') = ShareMngSystem('LI') * LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd');
LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd_I') = ShareMngSystem('IR') * LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd');
LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd_S') = ShareMngSystem('SS') * LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd');

LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd_H')$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', 'HI') * LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd');
LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd_L')$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', 'LI') * LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd');
LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd_I')$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', 'IR') * LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd');
LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd_S')$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', 'SS') * LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd');

PARAMETER chk_sums_luc_area_lc(LC_TYPES_BRAZIL);
chk_sums_luc_area_lc(LC_TYPES_BRAZIL) = sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, LC_TYPES_BRAZIL));
display chk_sums_luc_area_lc;

parameter chk_negative_values_luc_map_brazil(simucont_id_all, LC_TYPES_BRAZIL);
parameter chk_significant_neg_values_luc_map_brazil(simucont_id_all, LC_TYPES_BRAZIL);

chk_negative_values_luc_map_brazil(simucont_id_all, LC_TYPES_BRAZIL)$(LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, LC_TYPES_BRAZIL) < 0) =
                                                                         LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, LC_TYPES_BRAZIL);

chk_significant_neg_values_luc_map_brazil(simucont_id_all, LC_TYPES_BRAZIL)$(LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, LC_TYPES_BRAZIL) < -1e8) =
                                                                                 LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, LC_TYPES_BRAZIL);

display chk_significant_neg_values_luc_map_brazil;
display chk_negative_values_luc_map_brazil;

LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'OthAgri')$(LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'OthAgri') < 0) = 0;
LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'OthNatLnd')$(LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'OthNatLnd') < 0) = 0;
LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'WetLnd')$(LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'WetLnd') < 0) = 0;

scalar chk_sum_classes_new_luc_map_brazil;
chk_sum_classes_new_luc_map_brazil = sum(simucont_id_all, LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'CrpLnd') +
                                                      LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'OthAgri') +
                                                      LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'Grass') +
                                                      LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'Forest') +
                                                      LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'OthNatLnd') +
                                                      LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'NotRel') +
                                                      LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'WetLnd') +
                                                      LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, 'PAs'));
display chk_sum_classes_new_luc_map_brazil;

display chk_sums_luc_area_lc;

*-----------------------------------------------------------------------------
*------ Preparing information for double croping (soy and corn)
*-----------------------------------------------------------------------------

parameter LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS(simucont_id_all, ibgeCROPS, MngSystem);

LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS(simucont_id_all, 'SoyaDC', MngSystem) =  ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_SojaDoubleCrop');
LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS(simucont_id_all, 'SoyaNDC', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_SojaSemDoubleCrop');
LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS(simucont_id_all, 'CornDC', MngSystem) =  ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_MilhoDoubleCrop');
LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS(simucont_id_all, 'CornNDC', MngSystem) = ShareMngSystem(MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_MilhoSemDoubleCrop');

LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS(simucont_id_all, 'SoyaDC', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') =  ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_SojaDoubleCrop');
LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS(simucont_id_all, 'SoyaNDC', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_SojaSemDoubleCrop');
LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS(simucont_id_all, 'CornDC', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') =  ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_MilhoDoubleCrop');
LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS(simucont_id_all, 'CornNDC', MngSystem)$SimusContBiomeMap(simucont_id_all, 'caatinga') = ShareMngSystemBiome('caatinga', MngSystem) * 0.001 * ibge_mun_data_crops_into_simu(simucont_id_all, 'area_ha_2000_MilhoSemDoubleCrop');

*-----------------------------------------------------------------------------
*------ Preparing the area of PAs per land cover class
*-----------------------------------------------------------------------------

PARAMETER LAND_COVER_PAS_INTO_CLASSES(simucont_id_all, GlobiomClassesFromVegIbge);

LAND_COVER_PAS_INTO_CLASSES(simucont_id_all, 'WETLANDS') = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS', 'area_simu_veg_ibge_all_pas');
LAND_COVER_PAS_INTO_CLASSES(simucont_id_all, 'NOT_RELEVANT') = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'NOT_RELEVANT', 'area_simu_veg_ibge_all_pas');
LAND_COVER_PAS_INTO_CLASSES(simucont_id_all, 'OTHER_NATURAL_LAND') = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND', 'area_simu_veg_ibge_all_pas') +
                                                 LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP_PASTURE_OR_OTHER_NATURAL_LAND', 'area_simu_veg_ibge_all_pas');
LAND_COVER_PAS_INTO_CLASSES(simucont_id_all, 'FOREST') = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST', 'area_simu_veg_ibge_all_pas');

scalar sum_land_cover_pas_into_classes;
sum_land_cover_pas_into_classes = sum((simucont_id_all, GlobiomClassesFromVegIbge), LAND_COVER_PAS_INTO_CLASSES(simucont_id_all, GlobiomClassesFromVegIbge));
display sum_land_cover_pas_into_classes;

*-----------------------------------------------------------------------------
*------ Preparing the area of PAs per land cover class, per PA type
*-----------------------------------------------------------------------------

PARAMETER LAND_COVER_PAS_INTO_CLASSES_PROT_TYPE(simucont_id_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced);

LAND_COVER_PAS_INTO_CLASSES_PROT_TYPE(simucont_id_all, 'WETLANDS', VegIbgeMapVarsReduced) = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS', VegIbgeMapVarsReduced);
LAND_COVER_PAS_INTO_CLASSES_PROT_TYPE(simucont_id_all, 'NOT_RELEVANT', VegIbgeMapVarsReduced) = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'NOT_RELEVANT', VegIbgeMapVarsReduced);
LAND_COVER_PAS_INTO_CLASSES_PROT_TYPE(simucont_id_all, 'OTHER_NATURAL_LAND', VegIbgeMapVarsReduced) =
                                                                 LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND', VegIbgeMapVarsReduced) +
                                                                 LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP_PASTURE_OR_OTHER_NATURAL_LAND', VegIbgeMapVarsReduced);
LAND_COVER_PAS_INTO_CLASSES_PROT_TYPE(simucont_id_all, 'FOREST', VegIbgeMapVarsReduced) = LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST', VegIbgeMapVarsReduced);

LAND_COVER_PAS_INTO_CLASSES_PROT_TYPE(simucont_id_all, GlobiomClassesFromVegIbge, 'area_simu_veg_ibge_unprotected') = 0;

scalar sum_land_cover_pas_types_into_classes;
sum_land_cover_pas_types_into_classes = sum((simucont_id_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced),
                                                              LAND_COVER_PAS_INTO_CLASSES_PROT_TYPE(simucont_id_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced));
display sum_land_cover_pas_types_into_classes;

*-----------------------------------------------------------------------------
*------ excluding management class 'All' before exporting data
*-----------------------------------------------------------------------------

LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, ibgeCROPS, 'All') = 0;
LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS(simucont_id_all, ibgeCROPS, 'All') = 0;

*-----------------------------------------------------------------------------
*------ excluding management class 'All' before exporting data
*-----------------------------------------------------------------------------

PARAMETER TOTAL_TLUS_PER_SIMU(simucont_id_all, AllVarsMun);

TOTAL_TLUS_PER_SIMU(simucont_id_all, 'TLU_BOVI_2000') = sum(AllVarsMunEfetBov$(MapEfetBovTLUGlobiom(AllVarsMunEfetBov, 'TLU_BOVI_2000')),
                                                   TLUMultiplier(AllVarsMunEfetBov) * ibge_mun_data_animals_pasture_into_simu(simucont_id_all, AllVarsMunEfetBov));
TOTAL_TLUS_PER_SIMU(simucont_id_all, 'TLU_GOAT_2000') = sum(AllVarsMunEfetBov$(MapEfetBovTLUGlobiom(AllVarsMunEfetBov, 'TLU_GOAT_2000')),
                                                   TLUMultiplier(AllVarsMunEfetBov) * ibge_mun_data_animals_pasture_into_simu(simucont_id_all, AllVarsMunEfetBov));
TOTAL_TLUS_PER_SIMU(simucont_id_all, 'TLU_PTRY_2000') = sum(AllVarsMunEfetBov$(MapEfetBovTLUGlobiom(AllVarsMunEfetBov, 'TLU_PTRY_2000')),
                                                   TLUMultiplier(AllVarsMunEfetBov) * ibge_mun_data_animals_pasture_into_simu(simucont_id_all, AllVarsMunEfetBov));
TOTAL_TLUS_PER_SIMU(simucont_id_all, 'TLU_SHEP_2000') = sum(AllVarsMunEfetBov$(MapEfetBovTLUGlobiom(AllVarsMunEfetBov, 'TLU_SHEP_2000')),
                                                   TLUMultiplier(AllVarsMunEfetBov) * ibge_mun_data_animals_pasture_into_simu(simucont_id_all, AllVarsMunEfetBov));
TOTAL_TLUS_PER_SIMU(simucont_id_all, 'TLU_PIGS_2000') = sum(AllVarsMunEfetBov$(MapEfetBovTLUGlobiom(AllVarsMunEfetBov, 'TLU_PIGS_2000')),
                                                   TLUMultiplier(AllVarsMunEfetBov) * ibge_mun_data_animals_pasture_into_simu(simucont_id_all, AllVarsMunEfetBov));

TOTAL_TLUS_PER_SIMU(simucont_id_all, 'TLU_BOVI_2010') = sum(AllVarsMunEfetBov$(MapEfetBovTLUGlobiom(AllVarsMunEfetBov, 'TLU_BOVI_2010')),
                                                   TLUMultiplier(AllVarsMunEfetBov) * ibge_mun_data_animals_pasture_into_simu(simucont_id_all, AllVarsMunEfetBov));
TOTAL_TLUS_PER_SIMU(simucont_id_all, 'TLU_GOAT_2010') = sum(AllVarsMunEfetBov$(MapEfetBovTLUGlobiom(AllVarsMunEfetBov, 'TLU_GOAT_2010')),
                                                   TLUMultiplier(AllVarsMunEfetBov) * ibge_mun_data_animals_pasture_into_simu(simucont_id_all, AllVarsMunEfetBov));
TOTAL_TLUS_PER_SIMU(simucont_id_all, 'TLU_PTRY_2010') = sum(AllVarsMunEfetBov$(MapEfetBovTLUGlobiom(AllVarsMunEfetBov, 'TLU_PTRY_2010')),
                                                   TLUMultiplier(AllVarsMunEfetBov) * ibge_mun_data_animals_pasture_into_simu(simucont_id_all, AllVarsMunEfetBov));
TOTAL_TLUS_PER_SIMU(simucont_id_all, 'TLU_SHEP_2010') = sum(AllVarsMunEfetBov$(MapEfetBovTLUGlobiom(AllVarsMunEfetBov, 'TLU_SHEP_2010')),
                                                   TLUMultiplier(AllVarsMunEfetBov) * ibge_mun_data_animals_pasture_into_simu(simucont_id_all, AllVarsMunEfetBov));
TOTAL_TLUS_PER_SIMU(simucont_id_all, 'TLU_PIGS_2010') = sum(AllVarsMunEfetBov$(MapEfetBovTLUGlobiom(AllVarsMunEfetBov, 'TLU_PIGS_2010')),
                                                   TLUMultiplier(AllVarsMunEfetBov) * ibge_mun_data_animals_pasture_into_simu(simucont_id_all, AllVarsMunEfetBov));

*-----------------------------------------------------------------------------
*------ Salving the initial land use for crops into a new gams file
*-----------------------------------------------------------------------------

file SOLUTION5 /'.\Resultados\LUC_INIT_MAP_BRAZIL_TLUS_INTO_SIMUS.gms'/;

SOLUTION5.lw = 0;
SOLUTION5.lj = 10;
SOLUTION5.nw = 15;
SOLUTION5.nd = 3;
SOLUTION5.pw = 400;

PUT  SOLUTION5;

PUT "PARAMETER TOTAL_ANIMAL_TLUS_PER_SIMU(simucont_id_all, AllVarsMun)" /;
PUT "/" /;
LOOP((simucont_id_all, AllVarsMun)$(TOTAL_TLUS_PER_SIMU(simucont_id_all, AllVarsMun) > 0),
                 PUT @4 , simucont_id_all.tl,'.',AllVarsMun.tl:<60 @80;
                 PUT TOTAL_TLUS_PER_SIMU(simucont_id_all, AllVarsMun):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*-----------------------------------------------------------------------------
*------ Salving the initial land use for crops into a new gams file
*-----------------------------------------------------------------------------

file SOLUTION1 /'.\Resultados\LUC_INIT_MAP_BRAZIL_AREA_CROPS_INTO_SIMUS.gms'/;

SOLUTION1.lw = 0;
SOLUTION1.lj = 10;
SOLUTION1.nw = 15;
SOLUTION1.nd = 3;
SOLUTION1.pw = 400;

PUT  SOLUTION1;

PUT "PARAMETER LUC_INIT_MAP_BRAZIL_AREA_CROPS_SIMUS(simucont_id_all, ibgeCROPS, MngSystem)" /;
PUT "/" /;
LOOP((simucont_id_all, ibgeCROPS, MngSystem)$(LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, ibgeCROPS, MngSystem) > 0),
                 PUT @4 , simucont_id_all.tl,'.',ibgeCROPS.tl:<60,'.',MngSystem.tl @80;
                 PUT LUC_INIT_MAP_BRAZIL_AREA_CROPS(simucont_id_all, ibgeCROPS, MngSystem):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*-----------------------------------------------------------------------------
*------ Salving the initial land cover map into a new gams file
*-----------------------------------------------------------------------------

file SOLUTION /'.\Resultados\LUC_INIT_MAP_BRAZIL_AREA_LC_INTO_SIMUS.gms'/;

SOLUTION.lw = 0;
SOLUTION.lj = 10;
SOLUTION.nw = 15;
SOLUTION.nd = 3;
SOLUTION.pw = 400;

PUT  SOLUTION;

PUT "PARAMETER LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, LC_TYPES_BRAZIL)" /;
PUT "/" /;
LOOP((simucont_id_all,LC_TYPES_BRAZIL)$(LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, LC_TYPES_BRAZIL) > 0),
                 PUT @4 , simucont_id_all.tl,'.',LC_TYPES_BRAZIL.tl:<60 @80;
                 PUT LUC_INIT_MAP_BRAZIL_AREA_LC(simucont_id_all, LC_TYPES_BRAZIL):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*-----------------------------------------------------------------------------
*------ Salving the planted forest map into a new gams file
*-----------------------------------------------------------------------------

file SOLUTION2 /'.\Resultados\LUC_INIT_MAP_BRAZIL_AREA_PLT_FOREST_INTO_SIMUS.gms'/;

SOLUTION2.lw = 0;
SOLUTION2.lj = 10;
SOLUTION2.nw = 15;
SOLUTION2.nd = 3;
SOLUTION2.pw = 400;

PUT  SOLUTION2;

PUT "PARAMETER LUC_INIT_MAP_BRAZIL_AREA_PLT_FOREST_SIMUS(simucont_id_all)" /;
PUT "/" /;
LOOP((simucont_id_all)$(LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PLANTED_FOREST', 'area_total_simu_veg_ibge') > 0),
                 PUT @4 , simucont_id_all.tl @80;
                 PUT LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'PLANTED_FOREST', 'area_total_simu_veg_ibge'):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*-----------------------------------------------------------------------------
*------ Salving the allocation into PA's per Globiom class
*-----------------------------------------------------------------------------

file SOLUTION3 /'.\Resultados\LUC_INIT_ALL_PAS_INTO_CLASSES_BY_SIMU.gms'/;

SOLUTION3.lw = 0;
SOLUTION3.lj = 10;
SOLUTION3.nw = 15;
SOLUTION3.nd = 3;
SOLUTION3.pw = 400;

PUT  SOLUTION3;

PUT "PARAMETER LAND_COVER_PAS_INTO_CLASSES_BY_SIMU(simucont_id_all, GlobiomClassesFromVegIbge)" /;
PUT "/" /;
LOOP((simucont_id_all,GlobiomClassesFromVegIbge)$(LAND_COVER_PAS_INTO_CLASSES(simucont_id_all, GlobiomClassesFromVegIbge) > 0),
                 PUT @4 , simucont_id_all.tl,'.',GlobiomClassesFromVegIbge.tl:<70 @90;
                 PUT LAND_COVER_PAS_INTO_CLASSES(simucont_id_all, GlobiomClassesFromVegIbge):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*-----------------------------------------------------------------------------
*------ Salving the initial land use for double crops into a new gams file
*-----------------------------------------------------------------------------

file SOLUTION4 /'.\Resultados\LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS_INTO_SIMUS.gms'/;

SOLUTION4.lw = 0;
SOLUTION4.lj = 10;
SOLUTION4.nw = 15;
SOLUTION4.nd = 3;
SOLUTION4.pw = 400;

PUT  SOLUTION4;

PUT "PARAMETER LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS_SIMUS(simucont_id_all, ibgeCROPS, MngSystem)" /;
PUT "/" /;
LOOP((simucont_id_all, ibgeCROPS, MngSystem)$(LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS(simucont_id_all, ibgeCROPS, MngSystem) > 0),
                 PUT @4 , simucont_id_all.tl,'.',ibgeCROPS.tl:<60,'.',MngSystem.tl @80;
                 PUT LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS(simucont_id_all, ibgeCROPS, MngSystem):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*-----------------------------------------------------------------------------
*------ Salving the allocation into PA's per Globiom class and PA type
*-----------------------------------------------------------------------------

file SOLUTION6 /'.\Resultados\LUC_INIT_ALL_PAS_TYPES_INTO_CLASSES_BY_SIMU.gms'/;

SOLUTION6.lw = 0;
SOLUTION6.lj = 10;
SOLUTION6.nw = 15;
SOLUTION6.nd = 3;
SOLUTION6.pw = 400;

PUT  SOLUTION6;

PUT "PARAMETER LAND_COVER_PAS_TYPES_INTO_CLASSES_BY_SIMU(simucont_id_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced)" /;
PUT "/" /;
LOOP((simucont_id_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced)$
                         (LAND_COVER_PAS_INTO_CLASSES_PROT_TYPE(simucont_id_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced) > 0),

                 PUT @4 , simucont_id_all.tl,'.',GlobiomClassesFromVegIbge.tl:<30,'.',VegIbgeMapVarsReduced.tl:<50 @90;
                 PUT LAND_COVER_PAS_INTO_CLASSES_PROT_TYPE(simucont_id_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

$ONTEXT
$OFFTEXT

*------------------------------------------------------------------------------------------
*--------- the end                                                           --------------
*------------------------------------------------------------------------------------------
