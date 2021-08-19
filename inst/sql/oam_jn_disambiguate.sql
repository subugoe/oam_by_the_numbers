SELECT
  issn_l,
  ARRAY_AGG(STRUCT(container_title,
      publisher)
  ORDER BY
    year DESC, n DESC
  LIMIT
    1)[
OFFSET
  (0)].*
FROM (
  SELECT
    issn_l,
    container_title,
    publisher,
    EXTRACT (YEAR
    FROM
      issued) AS year,
    COUNT(DISTINCT doi) AS n
  FROM (
    SELECT
      SPLIT(issn, ",") AS issn,
      doi,
      container_title,
      publisher,
      issued
    FROM
      `api-project-764811344545.cr_instant.snapshot`
    WHERE
      NOT REGEXP_CONTAINS(title,'^Author Index$|^Back Cover|^Contents$|^Contents:|^Cover Image|^Cover Picture|^Editorial Board|^Front Cover|^Frontispiece|^Inside Back Cover|^Inside Cover|^Inside Front Cover|^Issue Information|^List of contents|^Masthead|^Title page|^Correction$|^Corrections to|^Corrections$|^Withdrawn')
      AND (NOT REGEXP_CONTAINS(page, '^S')
        OR page IS NULL)
      AND NOT REGEXP_CONTAINS(issue, '^S')) AS `tbl_cr`,
    UNNEST(issn) AS issn
  INNER JOIN
    `api-project-764811344545.tmp.oam_journals`
  ON
    issn = `api-project-764811344545.tmp.oam_journals`.`issn`
  GROUP BY
    issn_l,
    year,
    container_title,
    publisher
  ORDER BY
    n DESC )
WHERE
  year = 2020
GROUP BY
  issn_l