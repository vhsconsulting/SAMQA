-- liquibase formatted sql
-- changeset samqa:1754373926663 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\param_dates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/param_dates.sql:null:01a5ee8d5c9d75de89befb0d12684354ff42bdda:create

comment on table samqa.param_dates is
    'KOA System parameters, values changes by dates';

comment on column samqa.param_dates.param_date is
    'Start date for this value';

