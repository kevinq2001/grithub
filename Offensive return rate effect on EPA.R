install.packages("cfbfastR", "tidyverse")
library(tidyverse, cfbfastr)
view(cfbfastr)
load_cfb_pbp(2026)
"cfbfastR" %in% rownames(installed.packages())
# Check if API key is saved
Sys.getenv("CFBD_API_KEY")
install.packages("usethis")
usethis::edit_r_environ()
Sys.getenv("CFBD_API_KEY")
library(cfbfastR)
returning_production = load_cfb_returning_production(year=2025)
pbp = load_cfb_pbp(seasons = 2024:2025)
teams <- cfbd_team_info(only_fbs = FALSE)

returning <- returning_production |>
  mutate(team_id = as.integer(team_id)) |>
  left_join(teams |> select(team_id, school, conference, classification),
            by = "team_id")
view(returning)
epa <- pbp |>
  filter(home_team_division == "fbs",
         !is.na(pos_team),
         !is.na(EPA),
         pass == 1 | rush == 1) |>
  group_by (season, pos_team) |>
  summarize( plays = n(),
             epa_per_play = mean(EPA),
             .groups = "drop") |>
  filter(plays >=300)
epa_by_season <- epa |>
  select(season, pos_team, epa_per_play) |>
  pivot_wider(names_from = season,
              values_from = epa_per_play,
              names_prefix = "epa_") |>
  drop_na() |>
  mutate(epa_change = epa_2025 - epa_2024)

analysis <- epa_by_season |>
  left_join(returning |> select(school, off_returning),
            by = c("pos_team" = "school"))
cor(analysis$off_returning, analysis$epa_change)
summary(analysis$off_returning)

analysis |>
  slice_min(off_returning, n = 10)
analysis |>
  slice_max(off_returning, n = 10)

model <- lm(epa_2025 ~ epa_2024 + off_returning, data = analysis)
summary(model)
