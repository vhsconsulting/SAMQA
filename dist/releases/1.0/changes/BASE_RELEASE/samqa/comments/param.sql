-- liquibase formatted sql
-- changeset samqa:1754373926658 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\param.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/param.sql:null:18f88140b2c10aa4cd37aa94a75b6afe39ce09b5:create

comment on table samqa.param is
    'KOA System parameters';

