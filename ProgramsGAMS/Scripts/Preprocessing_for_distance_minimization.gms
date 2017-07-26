
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

$include .\Resultados\Distances_simus_to_municipalities.gms

PARAMETER ibge_mun_data(codmun_ibge_all, AllVarsMun) Data for land use and cover analysis (area in thousand ha);
PARAMETER CropPastureVegIBGE(simucont_id_all) Data for free area for pasture crops and planted forest (area in thousand ha);

$include .\Scripts\CheckingCorrecting_inputs_for_simus_allocation.gms

*--- weights for close municipalities and simulation units

parameter total_pairs;
total_pairs = card(simucont_id_all)*card(codmun_ibge_all);
display total_pairs;

parameter valid_dist_pairs;
valid_dist_pairs(codmun_ibge_all, simucont_id_all)$(valid_dists(codmun_ibge_all, simucont_id_all) or
                                  IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimU') or
                                  IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMun')) = 1;

scalar dimensao_valid_dists;
dimensao_valid_dists = card(valid_dists);
display dimensao_valid_dists;

scalar sum_valid_dists;
sum_valid_dists = sum((codmun_ibge_all, simucont_id_all), valid_dists(codmun_ibge_all, simucont_id_all));
display sum_valid_dists;

parameter nvalid_pairs;
nvalid_pairs = sum((codmun_ibge_all, simucont_id_all), valid_dist_pairs(codmun_ibge_all, simucont_id_all));
display nvalid_pairs;

scalar dimensao_valid_dists_adj;
dimensao_valid_dists_adj = card(valid_dists);
display dimensao_valid_dists_adj;

scalar sum_valid_dists_adj;
sum_valid_dists_adj = sum((codmun_ibge_all, simucont_id_all), valid_dists(codmun_ibge_all, simucont_id_all));
display sum_valid_dists_adj;

*-----------------------------------------------------------------
*--- finding minimum values to be allocated into simu's
*--- vamos usar apenas um percentual de florestas e wetlands
*-----------------------------------------------------------------

parameter total_inicial_available_crop_pasture_other_nat_land(simucont_id_all);
total_inicial_available_crop_pasture_other_nat_land(simucont_id_all) =
                                 LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP_PASTURE_OR_OTHER_NATURAL_LAND', 'area_total_simu_veg_ibge') -
                                 LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'CROP_PASTURE_OR_OTHER_NATURAL_LAND', 'area_simu_veg_ibge_all_pas') +
                                 LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND', 'area_total_simu_veg_ibge') -
                                 LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'OTHER_NATURAL_LAND', 'area_simu_veg_ibge_all_pas');

parameter total_inicial_available_forest_wetlands(simucont_id_all);
total_inicial_available_forest_wetlands(simucont_id_all)$(LegalAmazonBiomeMap(simucont_id_all)) =
                                 percentual_allowed_forest * (LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST', 'area_total_simu_veg_ibge') -
                                                              LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'FOREST', 'area_simu_veg_ibge_all_pas')) +
                                 percentual_allowed_wetlands * (LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS', 'area_total_simu_veg_ibge') -
                                                                LAND_COVER_IBGE_VEG_MAP(simucont_id_all, 'WETLANDS', 'area_simu_veg_ibge_all_pas'));

scalar sum_total_inicial_available_crop_pasture_other_nat_land;
scalar sum_total_inicial_available_forest_wetlands;

sum_total_inicial_available_crop_pasture_other_nat_land = sum(simucont_id_all, total_inicial_available_crop_pasture_other_nat_land(simucont_id_all));
sum_total_inicial_available_forest_wetlands = sum(simucont_id_all, total_inicial_available_forest_wetlands(simucont_id_all));

display sum_total_inicial_available_crop_pasture_other_nat_land;
display sum_total_inicial_available_forest_wetlands;

parameter soma_shareSimUInMun(simucont_id_all);
soma_shareSimUInMun(simucont_id_all) = sum(codmun_ibge_all, IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareSimUInMunSemAreasProt'));
display soma_shareSimUInMun;

parameter soma_shareMunInSimU(codmun_ibge_all);
soma_shareMunInSimU(codmun_ibge_all) = sum(simucont_id_all, IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimUSemAreasProt'));
display soma_shareMunInSimU;

scalar check_ibge_mun_data_crop_past;
check_ibge_mun_data_crop_past = sum(codmun_ibge_all, ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total'));
display check_ibge_mun_data_crop_past;

parameter naive_allocation_x(codmun_ibge_all, simucont_id_all);
naive_allocation_x(codmun_ibge_all, simucont_id_all) = ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') *
                                                                 IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimUSemAreasProt');

parameter initial_area_to_allocate_into_simu(simucont_id_all);

loop(simucont_id_all,
         initial_area_to_allocate_into_simu(simucont_id_all) = sum(codmun_ibge_all$(soma_shareMunInSimU(codmun_ibge_all) > 0),
                                                                               ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') *
                                                                               IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimUSemAreasProt'));
)

scalar sum_initial_area_to_allocate_into_simu;
sum_initial_area_to_allocate_into_simu = sum(simucont_id_all, initial_area_to_allocate_into_simu(simucont_id_all));
display sum_initial_area_to_allocate_into_simu;

*----------------------------------------------------------------------------------------------
*--- initial area to allocate considering only crop, pasture and other nat land available
*----------------------------------------------------------------------------------------------

parameter adjusted_area_to_allocate_into_simu_crop_past_natland(simucont_id_all);
adjusted_area_to_allocate_into_simu_crop_past_natland(simucont_id_all) = min(initial_area_to_allocate_into_simu(simucont_id_all),
                                                                 total_inicial_available_crop_pasture_other_nat_land(simucont_id_all));

scalar soma_adjusted_area_to_allocate_into_simu_crop_past_natland;
soma_adjusted_area_to_allocate_into_simu_crop_past_natland = sum(simucont_id_all, adjusted_area_to_allocate_into_simu_crop_past_natland(simucont_id_all));
display soma_adjusted_area_to_allocate_into_simu_crop_past_natland;

scalar sobra_adjusted_area_to_allocate_into_simu_crop_past_natland;
sobra_adjusted_area_to_allocate_into_simu_crop_past_natland = check_ibge_mun_data_crop_past - soma_adjusted_area_to_allocate_into_simu_crop_past_natland;
display sobra_adjusted_area_to_allocate_into_simu_crop_past_natland;

parameter remain_area_to_allocate_after_simu_crop_past_natland(codmun_ibge_all);

loop (codmun_ibge_all,
         remain_area_to_allocate_after_simu_crop_past_natland(codmun_ibge_all)$(soma_shareMunInSimU(codmun_ibge_all) > 0) =
                                                            ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') -
                                                            sum(simucont_id_all, ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') *
                                                                                 IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimUSemAreasProt') *
                                                                                 adjusted_area_to_allocate_into_simu_crop_past_natland(simucont_id_all)/
                                                                                 max(0.0001, initial_area_to_allocate_into_simu(simucont_id_all)));
)

scalar sobra_adjusted_area_to_allocate_from_mun_to_crop_past_natland;
sobra_adjusted_area_to_allocate_from_mun_to_crop_past_natland = sum(codmun_ibge_all, remain_area_to_allocate_after_simu_crop_past_natland(codmun_ibge_all));
display sobra_adjusted_area_to_allocate_from_mun_to_crop_past_natland;

*------------------------------------------------------------------------------------------------
*--- initial area to allocate considering on crop, pasture, other nat land, forest and wetlands
*------------------------------------------------------------------------------------------------

parameter initial_area_to_allocate_into_simu_forest_wetl(simucont_id_all);

loop(simucont_id_all,
         initial_area_to_allocate_into_simu_forest_wetl(simucont_id_all) = sum(codmun_ibge_all$(soma_shareMunInSimU(codmun_ibge_all) > 0),
                                                                               remain_area_to_allocate_after_simu_crop_past_natland(codmun_ibge_all) *
                                                                               IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimUSemAreasProt'));
)

scalar sum_initial_area_to_allocate_into_simu_forest_wetl;
sum_initial_area_to_allocate_into_simu_forest_wetl = sum(simucont_id_all, initial_area_to_allocate_into_simu_forest_wetl(simucont_id_all));
display sum_initial_area_to_allocate_into_simu_forest_wetl;

*-- o parâmetro abaixo inclui também área de crop, pasture e other nat land que sobrou do passo anterior

parameter adjusted_area_to_allocate_into_simu_forest_wetl(simucont_id_all);
adjusted_area_to_allocate_into_simu_forest_wetl(simucont_id_all) = min(initial_area_to_allocate_into_simu_forest_wetl(simucont_id_all),
                                                                       total_inicial_available_forest_wetlands(simucont_id_all) +
                                                                       max(0, total_inicial_available_crop_pasture_other_nat_land(simucont_id_all) -
                                                                              adjusted_area_to_allocate_into_simu_crop_past_natland(simucont_id_all)));

scalar soma_adjusted_area_to_allocate_into_simu_forest_wetl;
soma_adjusted_area_to_allocate_into_simu_forest_wetl = sum(simucont_id_all, adjusted_area_to_allocate_into_simu_forest_wetl(simucont_id_all));
display soma_adjusted_area_to_allocate_into_simu_forest_wetl;

scalar sobra_adjusted_area_to_allocate_into_simu;
sobra_adjusted_area_to_allocate_into_simu = check_ibge_mun_data_crop_past - soma_adjusted_area_to_allocate_into_simu_crop_past_natland -
                                                                            soma_adjusted_area_to_allocate_into_simu_forest_wetl;
display sobra_adjusted_area_to_allocate_into_simu;

*----------------------------------------------------------------------------------------------
*--- initial area to allocate consolidated
*----------------------------------------------------------------------------------------------

parameter adjusted_area_to_allocate_into_simu(simucont_id_all);
adjusted_area_to_allocate_into_simu(simucont_id_all) = max(0, adjusted_area_to_allocate_into_simu_crop_past_natland(simucont_id_all) +
                                                              adjusted_area_to_allocate_into_simu_forest_wetl(simucont_id_all) - 1e-10);

parameter min_allocation_into_simu(codmun_ibge_all, simucont_id_all);
min_allocation_into_simu(codmun_ibge_all, simucont_id_all) = ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') *
                                                    IntersectSimuIbgeArea(simucont_id_all, codmun_ibge_all, 'shareMunInSimUSemAreasProt') *
                                                    (adjusted_area_to_allocate_into_simu(simucont_id_all) /
                                                     initial_area_to_allocate_into_simu(simucont_id_all));

*--- ajustando para evitar excesso de alocação por municípios

parameter min_allocation_into_simu_inicial(codmun_ibge_all, simucont_id_all);
min_allocation_into_simu_inicial(codmun_ibge_all, simucont_id_all) = min_allocation_into_simu(codmun_ibge_all, simucont_id_all);

parameter min_allocation_into_mun_inicial(codmun_ibge_all);
min_allocation_into_mun_inicial(codmun_ibge_all) = sum(simucont_id_all, min_allocation_into_simu_inicial(codmun_ibge_all, simucont_id_all));

loop(codmun_ibge_all$(sum(simucont_id_all, min_allocation_into_simu_inicial(codmun_ibge_all, simucont_id_all)) >
                                                         ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total')),

         min_allocation_into_simu(codmun_ibge_all, simucont_id_all) = max(0, (min_allocation_into_simu_inicial(codmun_ibge_all, simucont_id_all) *
                                                                              ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') /
                                                                              min_allocation_into_mun_inicial(codmun_ibge_all)) - 1e-10);
)

parameter adjusted_area_to_allocate_into_simu_update(simucont_id_all);
adjusted_area_to_allocate_into_simu_update(simucont_id_all) = sum(codmun_ibge_all, min_allocation_into_simu(codmun_ibge_all, simucont_id_all));

adjusted_area_to_allocate_into_simu(simucont_id_all)$(adjusted_area_to_allocate_into_simu(simucont_id_all) >
                                                         adjusted_area_to_allocate_into_simu_update(simucont_id_all)) =
                                                         adjusted_area_to_allocate_into_simu_update(simucont_id_all);

scalar sum_adjusted_area_to_allocate_into_simu;
sum_adjusted_area_to_allocate_into_simu = sum(simucont_id_all, adjusted_area_to_allocate_into_simu(simucont_id_all));
display sum_adjusted_area_to_allocate_into_simu;

*----------------------------------------------------------------------------------------------
*--- checagem dos números gerados
*----------------------------------------------------------------------------------------------

scalar sum_min_allocation_into_simu;
sum_min_allocation_into_simu = sum((codmun_ibge_all, simucont_id_all), min_allocation_into_simu(codmun_ibge_all, simucont_id_all));
display sum_min_allocation_into_simu;

scalar razao_min_allocation_into_simu;
razao_min_allocation_into_simu = sum_min_allocation_into_simu / check_ibge_mun_data_crop_past;
display razao_min_allocation_into_simu;

parameter check_dif_min_allocation(simucont_id_all);
check_dif_min_allocation(simucont_id_all)$(sum(codmun_ibge_all, min_allocation_into_simu(codmun_ibge_all, simucont_id_all))
                                     - CropPastureVegIBGE(simucont_id_all) > 1e-8) = sum(codmun_ibge_all, min_allocation_into_simu(codmun_ibge_all, simucont_id_all))
                                                                            - CropPastureVegIBGE(simucont_id_all);
display check_dif_min_allocation;

parameter neg_crop_past_veg(simucont_id_all);
neg_crop_past_veg(simucont_id_all)$(CropPastureVegIBGE(simucont_id_all) < 0) = CropPastureVegIBGE(simucont_id_all);
display neg_crop_past_veg;

parameter neg_crop_past_mun(codmun_ibge_all);
neg_crop_past_mun(codmun_ibge_all)$(ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') < 0)
                 = ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total');
display neg_crop_past_mun;

parameter CropPastureVegIBGE_Original(simucont_id_all);
CropPastureVegIBGE_Original(simucont_id_all)$CropPastureVegIBGE(simucont_id_all) = CropPastureVegIBGE(simucont_id_all);

*ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') = ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total') / 1000000000;
*CropPastureVegIBGE(simucont_id_all) = CropPastureVegIBGE(simucont_id_all);

parameter soma_areas_available_crop_pasture_ibge;
soma_areas_available_crop_pasture_ibge = sum(simucont_id_all, CropPastureVegIBGE(simucont_id_all));
display soma_areas_available_crop_pasture_ibge;

parameter total_crop_past_ibge_check;
total_crop_past_ibge_check = sum(codmun_ibge_all, ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total'));
display total_crop_past_ibge_check;

*--- checando se os valores minimos por SIMU são menores do que os disponíveis de fato

parameter chk_simu_com_excesso_alocacao_minima(simucont_id_all);
chk_simu_com_excesso_alocacao_minima(simucont_id_all)$(adjusted_area_to_allocate_into_simu(simucont_id_all) > CropPastureVegIBGE(simucont_id_all)) =
                                                         adjusted_area_to_allocate_into_simu(simucont_id_all) - CropPastureVegIBGE(simucont_id_all);
display chk_simu_com_excesso_alocacao_minima;

parameter chk_simu_com_excesso_alocacao_minima_mun(simucont_id_all);
chk_simu_com_excesso_alocacao_minima_mun(simucont_id_all)$(sum(codmun_ibge_all, min_allocation_into_simu(codmun_ibge_all, simucont_id_all)) >
                                                                 CropPastureVegIBGE(simucont_id_all)) =
                                                           sum(codmun_ibge_all, min_allocation_into_simu(codmun_ibge_all, simucont_id_all)) -
                                                                 CropPastureVegIBGE(simucont_id_all);
display chk_simu_com_excesso_alocacao_minima_mun;

scalar max_dif_chk_simu_com_excesso_alocacao_minima_mun;
max_dif_chk_simu_com_excesso_alocacao_minima_mun = smax(simucont_id_all, chk_simu_com_excesso_alocacao_minima_mun(simucont_id_all));
display max_dif_chk_simu_com_excesso_alocacao_minima_mun;

*--- checando se os valores por município são compatíveis com os permitidos

parameter chk_mun_com_excesso_alocacao_minima(codmun_ibge_all);
chk_mun_com_excesso_alocacao_minima(codmun_ibge_all)$(sum(simucont_id_all, min_allocation_into_simu(codmun_ibge_all, simucont_id_all)) >
                                                                 ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total')) =
                                                           sum(simucont_id_all, min_allocation_into_simu(codmun_ibge_all, simucont_id_all)) -
                                                                 ibge_mun_data(codmun_ibge_all, 'area_crop_pasture_2000_total');
display chk_mun_com_excesso_alocacao_minima;

*------------------------------------------------------------------------------------------------------------*
*--------- the end                                                                             --------------*
*------------------------------------------------------------------------------------------------------------*
