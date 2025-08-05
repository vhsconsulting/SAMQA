-- liquibase formatted sql
-- changeset samqa:1754373926536 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\claim_interface.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/claim_interface.sql:null:f93c4037c2b3471dbf717a9af5809c444f761c67:create

comment on column samqa.claim_interface.er_acc_num is
    'Employer Account Number';

