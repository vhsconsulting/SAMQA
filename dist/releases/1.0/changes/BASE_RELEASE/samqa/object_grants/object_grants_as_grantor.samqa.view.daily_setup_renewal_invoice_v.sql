-- liquibase formatted sql
-- changeset SAMQA:1754373943487 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.daily_setup_renewal_invoice_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.daily_setup_renewal_invoice_v.sql:null:6ccba22d6578c7d822ef2386f8cf4f1ce4101a00:create

grant select on samqa.daily_setup_renewal_invoice_v to rl_sam_ro;

