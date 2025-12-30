library(DBI)
library(RSQLite)
library(dplyr)

con <- dbConnect(SQLite(), "/Users/yuiheilo/mortality.db")
death_causes <- read_csv("/Users/yuiheilo/Desktop/Misc/LifeExpectancy/Death_causes2.csv")
life_exp <- read_csv("/Users/yuiheilo/Desktop/Misc/LifeExpectancy/1- life-expectancy.csv")

dbWriteTable(con, "death_causes", death_causes, overwrite = TRUE)
dbWriteTable(con, "life_exp", life_exp, overwrite = TRUE)

#Clean
dbExecute(con, "UPDATE death_causes SET Country = Trim(Country);")
dbExecute(con, "UPDATE life_exp SET Country = Trim(Country);")

#Join datasets
dbExecute(con, "DROP TABLE IF EXISTS mortality_lifeexp;")

dbExecute(con,"
          CREATE TABLE mortality_lifeexp AS
          SElECT
          d.Country,
          l.\"Period life expectancy at birth - Sex: all - Age: 0\" AS life_expectancy,
          d.\"Acute hepatitis\" AS acute_hepatitis,
          d.\"Alcohol use disorders\" AS alcohol_use,
          d.\"Alzheimer's/dementias\" AS alzheimers,
          d.\"Cardiovascular diseases\" AS cardiovascular,
          d.\"Conflict/terrorismum\" AS conflict,
          d.Diabetes AS diabetes,
          d.\"Diarrheal diseases\" AS diarrheal,
          d.\"Digestive diseases\" AS digestive,
          d.Drowning AS drowning,
          d.Tuberculosis AS tuberculosis,
          d.\"Terrorism (deaths)\" AS terrorism,
          d.\"Self-harm\" AS self_harm,
          d.\"respiratory diseaseses\" AS respiratory,
          d.\"Protein-energy malnutrition\" AS protein_malnutrition,
          d.\"Road injuries\" AS road_injuries,
          d.Poisonings AS poisoning,
          d.Parkinson AS parkinson,
          d.\"Nutritional deficiencies\" AS nutritional_deficiency,
          d.\"Neonatal disorders\" AS neonatal,
          d.\"Fire/hot substances\" AS fire_heat,
          d.Neoplasms AS neoplasms,
          d.Meningitis AS meningitis,
          d.\"Maternal disorders\" AS maternal,
          d.Malaria AS malaria,
          d.\"HIV/AIDS\" AS hiv_aids,
          d.\"Drug use disorders\" AS drug,
          d.\"Environmental heat and cold exposure\" AS heat_cold,
          d.\"Exposure of nature\" AS nature,
          d.\"Lower respiratory infectionses\" AS lower_respiratory,
          d.\"liver diseases\" AS liver,
          d.\"kidney disease\" AS kidney,
          d.\"Interpersonal violence\" AS interpersonal
          FROM death_causes d
          JOIN life_exp l ON d.Country = l.Country
          WHERE l.Year = 2021;")

# Pull modeling data
df <- dbGetQuery(con, "
                       SELECT *
                       FROM mortality_lifeexp")
features <- df |> select(-Country, -life_expectancy)

# Check if table is populated
dbGetQuery(con, "SELECT COUNT(*) AS n FROM mortality_lifeexp")
dbGetQuery(con, "SELECT Country, life_expectancy FROM mortality_lifeexp LIMIT 10;")

dbDisconnect(con)
