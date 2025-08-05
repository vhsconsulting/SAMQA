-- liquibase formatted sql
-- changeset SAMQA:1754373945314 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.template_subscrib_hra_wel_mail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.template_subscrib_hra_wel_mail.sql:null:0c75bb6daa2b29640abc0d45dda4b230f688c6f5:create

grant select on samqa.template_subscrib_hra_wel_mail to rl_sam_ro;

grant select on samqa.template_subscrib_hra_wel_mail to rl_sam_rw;

grant select on samqa.template_subscrib_hra_wel_mail to rl_sam1_ro;

