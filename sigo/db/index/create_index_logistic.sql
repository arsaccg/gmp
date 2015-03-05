# inventory indexes
DROP INDEX ix_rep_inv_warehouses ON rep_inv_warehouses;
DROP INDEX ix_rep_inv_suppliers ON rep_inv_suppliers;
DROP INDEX ix_rep_inv_responsibles ON rep_inv_responsibles;
DROP INDEX ix_rep_inv_years ON rep_inv_years;
DROP INDEX ix_rep_inv_periods ON rep_inv_periods;
DROP INDEX ix_rep_inv_formats ON rep_inv_formats;
DROP INDEX ix_rep_inv_articles ON rep_inv_articles;

CREATE UNIQUE INDEX ix_rep_inv_warehouses ON rep_inv_warehouses (id, user);
CREATE UNIQUE INDEX ix_rep_inv_suppliers ON rep_inv_suppliers (id, user); -- OK
CREATE UNIQUE INDEX ix_rep_inv_responsibles ON rep_inv_responsibles (id, user);
CREATE UNIQUE INDEX ix_rep_inv_years ON rep_inv_years (id, user);
CREATE UNIQUE INDEX ix_rep_inv_periods ON rep_inv_periods (id, user);
CREATE UNIQUE INDEX ix_rep_inv_formats ON rep_inv_formats (id, user); -- OK
CREATE UNIQUE INDEX ix_rep_inv_articles ON rep_inv_articles (id, user); -- OK