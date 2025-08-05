-- liquibase formatted sql
-- changeset samqa:1754373926599 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\fee_names.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/fee_names.sql:null:315aea9c995a83d8865803d6d3c132b09741fe5d:create

comment on table samqa.fee_names is
    'Fee Types';

comment on column samqa.fee_names.fee_code is
    'For references only';

comment on column samqa.fee_names.fee_name is
    'Name of fee';

comment on column samqa.fee_names.fee_type is
    'Type of fee, 1 means exclude this fee from allowed contribution';

