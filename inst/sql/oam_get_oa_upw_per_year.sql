SELECT
  issn_l,
  cr_year,
  COUNT(DISTINCT cr_doi) AS upw_n,
  oa_status
FROM (
  SELECT
    issn_l,
    EXTRACT (YEAR
    FROM
      issued) AS cr_year,
    doi AS cr_doi
  FROM (
    SELECT
      SPLIT(issn, ",") AS issn,
      doi,
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
    issn = `api-project-764811344545.tmp.oam_journals`.`issn` )
INNER JOIN
  `api-project-764811344545.oadoi_full.upw_Feb21_08_21`
ON
  cr_doi = `api-project-764811344545.oadoi_full.upw_Feb21_08_21`.`doi`
WHERE
  cr_year > 2017
  AND cr_year < 2021
GROUP BY
  oa_status,
  issn_l,
  cr_year
ORDER BY
  issn_l,
  cr_year DESC