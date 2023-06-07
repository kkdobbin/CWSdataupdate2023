#Fuzzy name matching to identify which Mutuals are filed with the IRS

#Load IRS data
IRS <- read.csv("Data/eo_caIRS.csv")
nonprofit <- read.csv("Data/Private_nonprofit_systems.csv")
all <- read.csv("Data/March8draftdataallsystems.csv")

#reduce to smaller number of columns
nonprofit <- nonprofit[,-c(4,5,7,8,11,13,14,15:28)]
all <- all[,-c(4:27)]
nonprofit <- nonprofit[-c(736:738),]

#Compare names from each data set
library(stringdist)
library(fedmatch)

result <- fedmatch::merge_plus(
  data1 = IRS,
  match_type = "fuzzy",
  data2 = nonprofit, by.x = "NAME", by.y = "PWS_Name",
  unique_key_1 = "EIN", unique_key_2 = "PWSID",
  suffixes = c("_1", "_2"), fuzzy_settings = build_fuzzy_settings(maxDist = .5))



nonprofit$match <- stringsim(nonprofit$PWS_Name, IRS$NAME)

summary(Data_joined_small$match)
lowmatch <- Data_joined_small %>% filter(match < 0.5) 

write.csv(lowmatch, "Outputs/lownamematch2015to2021.csv")#REVIEW ALL OF THESE, look at NAs too

#Compare ownertype
Owner2015 <- read.csv("Data/2015CWSownertype.csv")
Owner2021 <- read.csv("Data/2021CWSownertype.csv")

Owner_joined <- full_join(Owner2015, Owner2021, by="PWS.ID")
Owner_joined <- Owner_joined %>% filter(complete.cases(Owner_joined))
Owner_joined$Owner.Type.x <- as.factor(Owner_joined$Owner.Type.x)
Owner_joined$Owner.Type.y <- as.factor(Owner_joined$Owner.Type.y)

Diffowner <- Owner_joined %>% filter(Owner_joined$Owner.Type.x != Owner_joined$Owner.Type.y)

write.csv(Diffowner, "Outputs/Ownershipchange2015to2021.csv")