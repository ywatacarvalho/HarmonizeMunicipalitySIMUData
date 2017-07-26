
SETS

year
/
         2000*2010
/

modelo
/
         modelo1, modelo2, modelo3, modelo4, modelo5, modelo6, modelo7, modelo8, modelo9, modelo10,
         modelo11, modelo12, modelo13, modelo14, modelo15, modelo16, modelo17, modelo18, modelo19, modelo20,
         media
/

Biome
/
         amazonia
         caatinga
         cerrado
         mata_atl
         pampa
         pantanal
/

MngSystem
/
         HI, LI, IR, SS, All
/
;

PARAMETER ShareMngSystem(MngSystem)
/
         HI      0.68
         LI      0.17
         IR      0.06
         SS      0.09
         All     1.00
/

PARAMETER ShareMngSystemBiome(Biome, MngSystem)
/
         caatinga.HI      0.10
         caatinga.LI      0.75
         caatinga.IR      0.06
         caatinga.SS      0.09
         caatinga.All     1.00
/;

display ShareMngSystemBiome;

ShareMngSystemBiome(Biome, MngSystem)$(ShareMngSystemBiome(Biome, MngSystem) <= 0) = ShareMngSystem(MngSystem);

display ShareMngSystemBiome;

SETS

ibgeCROPS
/
          Barl    Barley
          BeaD    DryBeans
          Cass    Cassava
          Corn    Corn
          Cott    Cotton
          Gnut    Groundnuts
          Pota    Potatos
          Rice    Rice
          Soya    Soybeans
          Srgh    Sorghum
          SugC    SugarCane
          Sunf    Sunflower
          SwPo    SweetPotatoes
          Whea    Whea
          OPAL    OilPalm

          SoyaDC  Soy with corn double crop (inside Soya)
          CornDC  Corn double crop (outside Corn)
          SoyaNDC Soy without corn double crop (inside Soya)
          CornNDC Corn no double crop (inside Corn)
/

LC_TYPES_BRAZIL
/
           SimUarea,
           CrpLnd, CrpLnd_H, CrpLnd_L, CrpLnd_I, CrpLnd_S, OthAgri, Grass,
           Forest, WetLnd, OthNatLnd, NotRel, PAs
/

GlobiomClassesFromVegIbge 'Classes for comparison between Globiom and IBGE vegetation map'
/
         CROP_PASTURE_OR_OTHER_NATURAL_LAND
         FOREST
         NOT_RELEVANT
         OTHER_NATURAL_LAND
         WETLANDS

         NOT_RELEVANT_MODIS
         NOT_RELEVANT_ADJUSTED
         NOT_RELEVANT_ADD_ADJUSTMENT

         PLANTED_FOREST
         FOREST_NON_PLANTED
         CROP
         PASTURE
         NOT_RELATED
         OTHER_NATURAL_LAND_ADJUSTED
         WETLANDS_ADJUSTED

         TOTAL_DERIVED_CLASSES
         TOTAL_IBGE_VEG_CLASSES
/

ModisVars 'Variables from Modis data'
/
         area_grass_thousand_ha
         area_croplands_thousand_ha
         area_evergreen_for_thousand_ha
         area_deciduous_for_thousand_ha
         area_forest_thousand_ha
         area_wetlands_thousand_ha
         area_not_rel_thousand_ha
         area_crop_past_othnatlnd_thousand_ha
/

VegIbgeMapVars 'Variables from the new land cover map using IBGE vegetation map'
/
         area_simu_veg_ibge_all_pas
         area_simu_veg_ibge_unprotected
         area_total_simu_veg_ibge
         area_veg_ibge_sosma_simu

         area_simu_veg_ibge_indigenous_land
         area_simu_veg_ibge_conserv_units
         area_simu_veg_ibge_public_forests
/

VegIbgeMapVarsReduced(VegIbgeMapVars) 'groups sum to the total area in Brazil'
/
         area_simu_veg_ibge_unprotected
         area_simu_veg_ibge_indigenous_land
         area_simu_veg_ibge_conserv_units
         area_simu_veg_ibge_public_forests
/

AllVarsMun 'All variables for municipality data'
/
         TLU_BOVI_2000
         TLU_GOAT_2000
         TLU_PTRY_2000
         TLU_SHEP_2000
         TLU_PIGS_2000

         TLU_BOVI_2010
         TLU_GOAT_2010
         TLU_PTRY_2010
         TLU_SHEP_2010
         TLU_PIGS_2010

         area_ha_2000_pasture_modis
         area_ha_2000_pasture
         area_ha_2010_pasture
         Efetivo_2000_Asininos
         Efetivo_2000_Bovinos
         Efetivo_2000_Caprinos
         Efetivo_2000_Coelhos
         Efetivo_2000_Equinos
         Efetivo_2000_Galinhas
         Efetivo_2000_Galos
         Efetivo_2000_Muares
         Efetivo_2000_Ovinos
         Efetivo_2000_Suinos
         Efetivo_2010_Asininos
         Efetivo_2010_Bovinos
         Efetivo_2010_Caprinos
         Efetivo_2010_Coelhos
         Efetivo_2010_Equinos
         Efetivo_2010_Galinhas
         Efetivo_2010_Galos
         Efetivo_2010_Muares
         Efetivo_2010_Ovinos
         Efetivo_2010_Suinos
         tlu_total_2000
         tlu_total_2010

         area_ha_2000_SojaDoubleCrop
         area_ha_2000_SojaSemDoubleCrop
         area_ha_2000_MilhoDoubleCrop
         area_ha_2000_MilhoSemDoubleCrop
         area_ha_2010_SojaDoubleCrop
         area_ha_2010_SojaSemDoubleCrop
         area_ha_2010_MilhoDoubleCrop
         area_ha_2010_MilhoSemDoubleCrop

         area_ha_2000_Algodao
         area_ha_2000_Amendoim
         area_ha_2000_Arroz
         area_ha_2000_Aveia
         area_ha_2000_Batata
         area_ha_2000_BatataDoce
         area_ha_2000_Cacau
         area_ha_2000_Cafe
         area_ha_2000_CanaDeAcucar
         area_ha_2000_CastanhaCaju
         area_ha_2000_Cevada
         area_ha_2000_CultPermanentes
         area_ha_2000_CultTemporarias
         area_ha_2000_Dende
         area_ha_2000_Feijao
         area_ha_2000_Mandioca
         area_ha_2000_Milho
         area_ha_2000_Sisal
         area_ha_2000_Soja
         area_ha_2000_Sorgo
         area_ha_2000_Trigo
         area_ha_2010_Algodao
         area_ha_2010_Amendoim
         area_ha_2010_Arroz
         area_ha_2010_Aveia
         area_ha_2010_Batata
         area_ha_2010_BatataDoce
         area_ha_2010_Cacau
         area_ha_2010_Cafe
         area_ha_2010_CanaDeAcucar
         area_ha_2010_CastanhaCaju
         area_ha_2010_Cevada
         area_ha_2010_CultPermanentes
         area_ha_2010_CultTemporarias
         area_ha_2010_Dende
         area_ha_2010_Feijao
         area_ha_2010_Girassol
         area_ha_2010_Mandioca
         area_ha_2010_Milho
         area_ha_2010_Sisal
         area_ha_2010_Soja
         area_ha_2010_Sorgo
         area_ha_2010_Trigo

         quant_ton_2000_SojaDoubleCrop
         quant_ton_2000_SojaSemDoubleCrop
         quant_ton_2000_MilhoDoubleCrop
         quant_ton_2000_MilhoSemDoubleCrop
         quant_ton_2010_SojaDoubleCrop
         quant_ton_2010_SojaSemDoubleCrop
         quant_ton_2010_MilhoDoubleCrop
         quant_ton_2010_MilhoSemDoubleCrop

         quant_ton_2000_Algodao
         quant_ton_2000_Amendoim
         quant_ton_2000_Arroz
         quant_ton_2000_Aveia
         quant_ton_2000_Batata
         quant_ton_2000_BatataDoce
         quant_ton_2000_Cacau
         quant_ton_2000_Cafe
         quant_ton_2000_CanaDeAcucar
         quant_ton_2000_CastanhaCaju
         quant_ton_2000_Cevada
         quant_ton_2000_Dende
         quant_ton_2000_Feijao
         quant_ton_2000_Mandioca
         quant_ton_2000_Milho
         quant_ton_2000_Sisal
         quant_ton_2000_Soja
         quant_ton_2000_Sorgo
         quant_ton_2000_Trigo
         quant_ton_2010_Algodao
         quant_ton_2010_Amendoim
         quant_ton_2010_Arroz
         quant_ton_2010_Aveia
         quant_ton_2010_Batata
         quant_ton_2010_BatataDoce
         quant_ton_2010_Cacau
         quant_ton_2010_Cafe
         quant_ton_2010_CanaDeAcucar
         quant_ton_2010_CastanhaCaju
         quant_ton_2010_Cevada
         quant_ton_2010_Dende
         quant_ton_2010_Feijao
         quant_ton_2010_Girassol
         quant_ton_2010_Mandioca
         quant_ton_2010_Milho
         quant_ton_2010_Sisal
         quant_ton_2010_Soja
         quant_ton_2010_Sorgo
         quant_ton_2010_Trigo

         valor_2000_SojaDoubleCrop
         valor_2000_SojaSemDoubleCrop
         valor_2000_MilhoDoubleCrop
         valor_2000_MilhoSemDoubleCrop
         valor_2010_SojaDoubleCrop
         valor_2010_SojaSemDoubleCrop
         valor_2010_MilhoDoubleCrop
         valor_2010_MilhoSemDoubleCrop

         valor_2000_Algodao
         valor_2000_Amendoim
         valor_2000_Arroz
         valor_2000_Aveia
         valor_2000_Batata
         valor_2000_BatataDoce
         valor_2000_Cacau
         valor_2000_Cafe
         valor_2000_CanaDeAcucar
         valor_2000_CastanhaCaju
         valor_2000_Cevada
         valor_2000_CultPermanentes
         valor_2000_CultTemporarias
         valor_2000_Dende
         valor_2000_Feijao
         valor_2000_Mandioca
         valor_2000_Milho
         valor_2000_Sisal
         valor_2000_Soja
         valor_2000_Sorgo
         valor_2000_Trigo
         valor_2010_Algodao
         valor_2010_Amendoim
         valor_2010_Arroz
         valor_2010_Aveia
         valor_2010_Batata
         valor_2010_BatataDoce
         valor_2010_Cacau
         valor_2010_Cafe
         valor_2010_CanaDeAcucar
         valor_2010_CastanhaCaju
         valor_2010_Cevada
         valor_2010_CultPermanentes
         valor_2010_CultTemporarias
         valor_2010_Dende
         valor_2010_Feijao
         valor_2010_Girassol
         valor_2010_Mandioca
         valor_2010_Milho
         valor_2010_Sisal
         valor_2010_Soja
         valor_2010_Sorgo
         valor_2010_Trigo

         area_ha_2006_AgroForestSystems
         area_ha_2006_ForestNativeLegalReserve
         area_ha_2006_ForestNativeOthers
         area_ha_2006_ForestPlanted
         num_estabs_2006_AgroForestSystems
         num_estabs_2006_ForestNativeLegalReserve
         num_estabs_2006_ForestNativeOthers
         num_estabs_2006_ForestPlanted

         all_crops_area_ibge_2000
         temp_crops_ha_2000_ibge
         perm_crops_ha_2000_ibge
         allglobiom_crops_area_ibge_2000
         bovi_count_ibge_2000
         lut_total_ibge_2000
         area_sum_grass_ibge_2006
         area_grass_2000_ibge_total
         area_crop_pasture_2000_total
         area_planted_forest_2006_ibge
/

AllVarsMunEfetBov(AllVarsMun)
/
         Efetivo_2000_Asininos
         Efetivo_2000_Bovinos
         Efetivo_2000_Caprinos
         Efetivo_2000_Coelhos
         Efetivo_2000_Equinos
         Efetivo_2000_Galinhas
         Efetivo_2000_Galos
         Efetivo_2000_Muares
         Efetivo_2000_Ovinos
         Efetivo_2000_Suinos

         Efetivo_2010_Asininos
         Efetivo_2010_Bovinos
         Efetivo_2010_Caprinos
         Efetivo_2010_Coelhos
         Efetivo_2010_Equinos
         Efetivo_2010_Galinhas
         Efetivo_2010_Galos
         Efetivo_2010_Muares
         Efetivo_2010_Ovinos
         Efetivo_2010_Suinos
/

MapEfetBovTLUGlobiom(AllVarsMunEfetBov, AllVarsMun)    Mapping between Globiom TLU classes and IBGE data (need some revision)
/
         Efetivo_2000_Asininos .  TLU_BOVI_2000
         Efetivo_2000_Bovinos  .  TLU_BOVI_2000
         Efetivo_2000_Caprinos .  TLU_GOAT_2000
         Efetivo_2000_Coelhos  .  TLU_PTRY_2000
         Efetivo_2000_Equinos  .  TLU_BOVI_2000
         Efetivo_2000_Galinhas .  TLU_PTRY_2000
         Efetivo_2000_Galos    .  TLU_PTRY_2000
         Efetivo_2000_Muares   .  TLU_BOVI_2000
         Efetivo_2000_Ovinos   .  TLU_SHEP_2000
         Efetivo_2000_Suinos   .  TLU_PIGS_2000

         Efetivo_2010_Asininos  . TLU_BOVI_2010
         Efetivo_2010_Bovinos   . TLU_BOVI_2010
         Efetivo_2010_Caprinos  . TLU_GOAT_2010
         Efetivo_2010_Coelhos   . TLU_PTRY_2010
         Efetivo_2010_Equinos   . TLU_BOVI_2010
         Efetivo_2010_Galinhas  . TLU_PTRY_2010
         Efetivo_2010_Galos     . TLU_PTRY_2010
         Efetivo_2010_Muares    . TLU_BOVI_2010
         Efetivo_2010_Ovinos    . TLU_SHEP_2010
         Efetivo_2010_Suinos    . TLU_PIGS_2010
/
;

display ibgeCROPS;

PARAMETER TLUMultiplier(AllVarsMunEfetBov)
/
         Efetivo_2000_Asininos   0.0
         Efetivo_2000_Bovinos    0.7
         Efetivo_2000_Caprinos   0.1
         Efetivo_2000_Coelhos    0.0
         Efetivo_2000_Equinos    0.0
         Efetivo_2000_Galinhas   0.01
         Efetivo_2000_Galos      0.01
         Efetivo_2000_Muares     0.0
         Efetivo_2000_Ovinos     0.1
         Efetivo_2000_Suinos     0.25

         Efetivo_2010_Asininos   0.0
         Efetivo_2010_Bovinos    0.7
         Efetivo_2010_Caprinos   0.1
         Efetivo_2010_Coelhos    0.0
         Efetivo_2010_Equinos    0.0
         Efetivo_2010_Galinhas   0.01
         Efetivo_2010_Galos      0.01
         Efetivo_2010_Muares     0.0
         Efetivo_2010_Ovinos     0.1
         Efetivo_2010_Suinos     0.25
/
;

SETS

IntersectSimuIBGE 'Variables for intersection between ibge area and simu area'
/
         AreaInter
         AreaSimU
         AreaSimUbyInter
         AreaMun
         AreaMunbyInter
         shareSimUInMun
         shareMunInSimU
         AreaInterSemAreasProt
         shareSimUInMunSemAreasProt
         shareMunInSimUSemAreasProt
/

Coordinate 'Coordinates for geometries'
/
         X
         Y
/

;
