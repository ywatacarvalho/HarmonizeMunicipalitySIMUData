
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

parameter soma_classes_from_veg_ibge_area_total(GlobiomClassesFromVegIbge);
soma_classes_from_veg_ibge_area_total(GlobiomClassesFromVegIbge) =
         sum(simucont_id_all, LAND_COVER_IBGE_VEG_MAP(simucont_id_all, GlobiomClassesFromVegIbge, 'area_total_simu_veg_ibge'));
display soma_classes_from_veg_ibge_area_total;

parameter soma_classes_from_veg_ibge_area_pas(GlobiomClassesFromVegIbge);
soma_classes_from_veg_ibge_area_pas(GlobiomClassesFromVegIbge) =
         sum(simucont_id_all, LAND_COVER_IBGE_VEG_MAP(simucont_id_all, GlobiomClassesFromVegIbge, 'area_simu_veg_ibge_all_pas'));
display soma_classes_from_veg_ibge_area_pas;

$include .\Scripts\CheckingCorrecting_inputs_for_simus_allocation.gms

*--- weights for close municipalities and simulation units

$include .\Scripts\preparing_distance_data.gms

*----------------------------------------------------------------------------------------------------------------*
*---------                                            the end                                      --------------*
*----------------------------------------------------------------------------------------------------------------*
