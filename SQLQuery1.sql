select *
from CovidDeaths
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4 

-- select the necessary data
select location, date, total_cases, new_cases, total_deaths, population
from covidDeaths

order by 1,2 

-- Total cases vs deaths of covid in Nigeria 
select location, date, total_cases, total_deaths
from covidDeaths
where location = 'Nigeria'
order by 1,2

-- Likelihood of dying from covid in Nigeria 
select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 As CovidDeathLikelihoodPercent
from covidDeaths
where location = 'Nigeria'
order by 1,2

