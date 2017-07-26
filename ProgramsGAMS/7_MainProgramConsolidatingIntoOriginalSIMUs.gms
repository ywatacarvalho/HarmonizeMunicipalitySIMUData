
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

$include .\Scripts\CheckingCorrecting_inputs_for_simus_allocation.gms

*---------------------------------------------------------------------
*----- uploaded data
*---------------------------------------------------------------------

$include .\Resultados\IBGE_municipality_data_planted_forests_into_simus.gms
$include .\Resultados\IBGE_municipality_data_animals_pasture_into_simus.gms
$include .\Resultados\IBGE_municipality_data_crops_into_simus.gms

$include .\Resultados\LUC_INIT_MAP_BRAZIL_AREA_CROPS_INTO_SIMUS.gms
$include .\Resultados\LUC_INIT_MAP_BRAZIL_AREA_LC_INTO_SIMUS.gms
$include .\Resultados\LUC_INIT_MAP_BRAZIL_AREA_PLT_FOREST_INTO_SIMUS.gms
$include .\Resultados\LUC_INIT_ALL_PAS_INTO_CLASSES_BY_SIMU.gms
$include .\Resultados\LUC_INIT_MAP_BRAZIL_TLUS_INTO_SIMUS.gms
$include .\Resultados\LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS_INTO_SIMUS.gms
$include .\Resultados\LUC_INIT_ALL_PAS_TYPES_INTO_CLASSES_BY_SIMU.gms

*---------------------------------------------------------------------
*----- organizing data per original SIMUs
*---------------------------------------------------------------------

PARAMETER LAND_COVER_PAS_TYPES_INTO_CLASSES_BY_SIMU_ORI(simuid_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced);

LAND_COVER_PAS_TYPES_INTO_CLASSES_BY_SIMU_ORI(simuid_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced) =
         sum(simucont_id_all$(MapSimuContToSimu(simucont_id_all, simuid_all)),
             LAND_COVER_PAS_TYPES_INTO_CLASSES_BY_SIMU(simucont_id_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced));

PARAMETER LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS_SIMUS_ORI(simuid_all, ibgeCROPS, MngSystem);

LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS_SIMUS_ORI(simuid_all, ibgeCROPS, MngSystem) =
         sum(simucont_id_all$(MapSimuContToSimu(simucont_id_all, simuid_all)),
             LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS_SIMUS(simucont_id_all, ibgeCROPS, MngSystem));

PARAMETER LAND_COVER_PAS_INTO_CLASSES_BY_SIMU_ORI(simuid_all, GlobiomClassesFromVegIbge);

LAND_COVER_PAS_INTO_CLASSES_BY_SIMU_ORI(simuid_all, GlobiomClassesFromVegIbge) =
         sum(simucont_id_all$(MapSimuContToSimu(simucont_id_all, simuid_all)),
             LAND_COVER_PAS_INTO_CLASSES_BY_SIMU(simucont_id_all, GlobiomClassesFromVegIbge));

PARAMETER LUC_INIT_MAP_BRAZIL_AREA_PLT_FOREST_SIMUS_ORI(simuid_all);

LUC_INIT_MAP_BRAZIL_AREA_PLT_FOREST_SIMUS_ORI(simuid_all) =
         sum(simucont_id_all$(MapSimuContToSimu(simucont_id_all, simuid_all)),
             LUC_INIT_MAP_BRAZIL_AREA_PLT_FOREST_SIMUS(simucont_id_all));

PARAMETER LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS_ORI(simuid_all, LC_TYPES_BRAZIL);

LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS_ORI(simuid_all, LC_TYPES_BRAZIL) =
         sum(simucont_id_all$(MapSimuContToSimu(simucont_id_all, simuid_all)),
             LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simucont_id_all, LC_TYPES_BRAZIL));

PARAMETER LUC_INIT_MAP_BRAZIL_AREA_CROPS_SIMUS_ORI(simuid_all, ibgeCROPS, MngSystem);

LUC_INIT_MAP_BRAZIL_AREA_CROPS_SIMUS_ORI(simuid_all, ibgeCROPS, MngSystem) =
         sum(simucont_id_all$(MapSimuContToSimu(simucont_id_all, simuid_all)),
             LUC_INIT_MAP_BRAZIL_AREA_CROPS_SIMUS(simucont_id_all, ibgeCROPS, MngSystem));

PARAMETER TOTAL_ANIMAL_TLUS_PER_SIMU_ORI(simuid_all, AllVarsMun);

TOTAL_ANIMAL_TLUS_PER_SIMU_ORI(simuid_all, AllVarsMun) =
         sum(simucont_id_all$(MapSimuContToSimu(simucont_id_all, simuid_all)),
             TOTAL_ANIMAL_TLUS_PER_SIMU(simucont_id_all, AllVarsMun));

*-----------------------------------------------------------------------------
*------ Salving the initial land use for crops into a new gams file
*-----------------------------------------------------------------------------

*$ONTEXT
file SOLUTION5 /'.\ConsolidacaoSIMUs\LUC_INIT_MAP_BRAZIL_TLUS_INTO_SIMUS.gms'/;

SOLUTION5.lw = 0;
SOLUTION5.lj = 10;
SOLUTION5.nw = 15;
SOLUTION5.nd = 3;
SOLUTION5.pw = 400;

PUT  SOLUTION5;

PUT "PARAMETER TOTAL_ANIMAL_TLUS_PER_SIMU(simuid_all, AllVarsMun)" /;
PUT "/" /;
LOOP((simuid_all, AllVarsMun)$(TOTAL_ANIMAL_TLUS_PER_SIMU_ORI(simuid_all, AllVarsMun) > 0),
                 PUT @4 , simuid_all.tl:<12,'.',AllVarsMun.tl:<60 @80;
                 PUT TOTAL_ANIMAL_TLUS_PER_SIMU_ORI(simuid_all, AllVarsMun):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*-----------------------------------------------------------------------------
*------ Salving the initial land use for crops into a new gams file
*-----------------------------------------------------------------------------

file SOLUTION6 /'.\ConsolidacaoSIMUs\LUC_INIT_MAP_BRAZIL_AREA_CROPS_INTO_SIMUS.gms'/;

SOLUTION6.lw = 0;
SOLUTION6.lj = 10;
SOLUTION6.nw = 15;
SOLUTION6.nd = 3;
SOLUTION6.pw = 400;

PUT  SOLUTION6;

PUT "PARAMETER LUC_INIT_MAP_BRAZIL_AREA_CROPS_SIMUS(simucont_id_all, ibgeCROPS, MngSystem)" /;
PUT "/" /;
LOOP((simuid_all, ibgeCROPS, MngSystem)$(LUC_INIT_MAP_BRAZIL_AREA_CROPS_SIMUS_ORI(simuid_all, ibgeCROPS, MngSystem) > 0),
                 PUT @4 , simuid_all.tl:<12,'.',ibgeCROPS.tl:<60,'.',MngSystem.tl @80;
                 PUT LUC_INIT_MAP_BRAZIL_AREA_CROPS_SIMUS_ORI(simuid_all, ibgeCROPS, MngSystem):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

*-----------------------------------------------------------------------------
*------ Salving the initial land cover map into a new gams file
*-----------------------------------------------------------------------------

file SOLUTION /'.\ConsolidacaoSIMUs\LUC_INIT_MAP_BRAZIL_AREA_LC_INTO_SIMUS.gms'/;

SOLUTION.lw = 0;
SOLUTION.lj = 10;
SOLUTION.nw = 15;
SOLUTION.nd = 3;
SOLUTION.pw = 400;

PUT  SOLUTION;

PUT "PARAMETER LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS(simuid_all, LC_TYPES_BRAZIL)" /;
PUT "/" /;
LOOP((simuid_all,LC_TYPES_BRAZIL)$(LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS_ORI(simuid_all, LC_TYPES_BRAZIL) > 0),
                 PUT @4 , simuid_all.tl:<12,'.',LC_TYPES_BRAZIL.tl:<60 @80;
                 PUT LUC_INIT_MAP_BRAZIL_AREA_LC_SIMUS_ORI(simuid_all, LC_TYPES_BRAZIL):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*-----------------------------------------------------------------------------
*------ Salving the allocation into PA's per Globiom class and PA type
*-----------------------------------------------------------------------------

file SOLUTION1 /'.\ConsolidacaoSIMUs\LUC_INIT_ALL_PAS_TYPES_INTO_CLASSES_BY_SIMU.gms'/;

SOLUTION1.lw = 0;
SOLUTION1.lj = 10;
SOLUTION1.nw = 15;
SOLUTION1.nd = 3;
SOLUTION1.pw = 400;

PUT  SOLUTION1;

PUT "PARAMETER LAND_COVER_PAS_TYPES_INTO_CLASSES_BY_SIMU(simuid_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced)" /;
PUT "/" /;
LOOP((simuid_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced)$
                         (LAND_COVER_PAS_TYPES_INTO_CLASSES_BY_SIMU_ORI(simuid_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced) > 0),

                 PUT @4 , simuid_all.tl:<12,'.',GlobiomClassesFromVegIbge.tl:<30,'.',VegIbgeMapVarsReduced.tl:<50 @90;
                 PUT LAND_COVER_PAS_TYPES_INTO_CLASSES_BY_SIMU_ORI(simuid_all, GlobiomClassesFromVegIbge, VegIbgeMapVarsReduced):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*-----------------------------------------------------------------------------
*------ Salving the initial land use for double crops into a new gams file
*-----------------------------------------------------------------------------

file SOLUTION4 /'.\ConsolidacaoSIMUs\LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS_INTO_SIMUS.gms'/;

SOLUTION4.lw = 0;
SOLUTION4.lj = 10;
SOLUTION4.nw = 15;
SOLUTION4.nd = 3;
SOLUTION4.pw = 400;

PUT  SOLUTION4;

PUT "PARAMETER LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS_SIMUS(simuid_all, ibgeCROPS, MngSystem)" /;
PUT "/" /;
LOOP((simuid_all, ibgeCROPS, MngSystem)$(LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS_SIMUS_ORI(simuid_all, ibgeCROPS, MngSystem) > 0),
                 PUT @4 , simuid_all.tl:<12,'.',ibgeCROPS.tl:<60,'.',MngSystem.tl @90;
                 PUT LUC_INIT_MAP_BRAZIL_AREA_DOUBLE_CROPS_SIMUS_ORI(simuid_all, ibgeCROPS, MngSystem):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*-----------------------------------------------------------------------------
*------ Salving the allocation into PA's per Globiom class
*-----------------------------------------------------------------------------

file SOLUTION3 /'.\ConsolidacaoSIMUs\LUC_INIT_ALL_PAS_INTO_CLASSES_BY_SIMU.gms'/;

SOLUTION3.lw = 0;
SOLUTION3.lj = 10;
SOLUTION3.nw = 15;
SOLUTION3.nd = 3;
SOLUTION3.pw = 400;

PUT  SOLUTION3;

PUT "PARAMETER LAND_COVER_PAS_INTO_CLASSES_BY_SIMU(simuid_all, GlobiomClassesFromVegIbge)" /;
PUT "/" /;
LOOP((simuid_all,GlobiomClassesFromVegIbge)$(LAND_COVER_PAS_INTO_CLASSES_BY_SIMU_ORI(simuid_all, GlobiomClassesFromVegIbge) > 0),
                 PUT @4 , simuid_all.tl:<12,'.',GlobiomClassesFromVegIbge.tl:<70 @90;
                 PUT LAND_COVER_PAS_INTO_CLASSES_BY_SIMU_ORI(simuid_all, GlobiomClassesFromVegIbge):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;

*-----------------------------------------------------------------------------
*------ Salving the planted forest map into a new gams file
*-----------------------------------------------------------------------------

file SOLUTION2 /'.\ConsolidacaoSIMUs\LUC_INIT_MAP_BRAZIL_AREA_PLT_FOREST_INTO_SIMUS.gms'/;

SOLUTION2.lw = 0;
SOLUTION2.lj = 10;
SOLUTION2.nw = 15;
SOLUTION2.nd = 3;
SOLUTION2.pw = 400;

PUT  SOLUTION2;

PUT "PARAMETER LUC_INIT_MAP_BRAZIL_AREA_PLT_FOREST_SIMUS(simuid_all)" /;
PUT "/" /;
LOOP((simuid_all)$(LUC_INIT_MAP_BRAZIL_AREA_PLT_FOREST_SIMUS_ORI(simuid_all) > 0),
                 PUT @4 , simuid_all.tl @80;
                 PUT LUC_INIT_MAP_BRAZIL_AREA_PLT_FOREST_SIMUS_ORI(simuid_all):30:8
                 PUT /;
)
PUT "/" /;
PUT ";" /;

PUTCLOSE;


$ontext
$OFFTEXT

*-----------------------------------------------------------------------------------------------------
*--------- the end
*-----------------------------------------------------------------------------------------------------
