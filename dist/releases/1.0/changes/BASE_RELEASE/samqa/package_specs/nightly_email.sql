-- liquibase formatted sql
-- changeset SAMQA:1754374133583 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\nightly_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/nightly_email.sql:null:889d6a6a5ef586313496ccde07e1ec93c3037eed:create

create or replace package samqa.nightly_email as
    procedure pending_accounts;

    procedure error_accounts;

end nightly_email;
/

