create or replace package samqa.nightly_email as
    procedure pending_accounts;

    procedure error_accounts;

end nightly_email;
/


-- sqlcl_snapshot {"hash":"889d6a6a5ef586313496ccde07e1ec93c3037eed","type":"PACKAGE_SPEC","name":"NIGHTLY_EMAIL","schemaName":"SAMQA","sxml":""}