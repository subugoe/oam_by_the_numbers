SELECT
  issn_l,
  EXTRACT (YEAR
  FROM
    issued) AS cr_year,
  COUNT(DISTINCT cr_doi) AS n
FROM (
  SELECT
    SPLIT(issn, ",") AS issn,
    doi AS cr_doi,
    issued
  FROM
    `api-project-764811344545.cr_instant.snapshot`
  WHERE
    NOT REGEXP_CONTAINS(title,'^Author Index$|^Back Cover|^Contents$|^Contents:|^Cover Image|^Cover Picture|^Editorial Board|^Front Cover|^Frontispiece|^Inside Back Cover|^Inside Cover|^Inside Front Cover|^Issue Information|^List of contents|^Masthead|^Title page|^Correction$|^Corrections to|^Corrections$|^Withdrawn')
    AND (NOT REGEXP_CONTAINS(page, '^S')
      OR page IS NULL) -- include online only articles, lacking page or issue
          AND (NOT REGEXP_CONTAINS(issue, '^S')
      OR issue IS NULL) ) AS `tbl_cr`,
  UNNEST(issn) AS issn
INNER JOIN
  `api-project-764811344545.tmp.oam_journals`
ON
  issn = `api-project-764811344545.tmp.oam_journals`.`issn`
INNER JOIN
  `api-project-764811344545.tmp.h2020_dois`
ON
  LOWER(cr_doi) = LOWER(`api-project-764811344545.tmp.h2020_dois`.doi)
GROUP BY
  issn_l,
  cr_year
ORDER BY
  n DESC
