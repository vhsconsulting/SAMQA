grant alter on samqa.bank_accounts to shavee;

grant delete on samqa.bank_accounts to rl_sam_rw;

grant delete on samqa.bank_accounts to shavee;

grant index on samqa.bank_accounts to shavee;

grant insert on samqa.bank_accounts to rl_sam_rw;

grant insert on samqa.bank_accounts to shavee;

grant select on samqa.bank_accounts to shavee;

grant select on samqa.bank_accounts to rl_sam_ro;

grant select on samqa.bank_accounts to rl_sam_rw;

grant select on samqa.bank_accounts to rl_sam1_ro;

grant update on samqa.bank_accounts to shavee;

grant update on samqa.bank_accounts to rl_sam_rw;

grant references on samqa.bank_accounts to shavee;

grant read on samqa.bank_accounts to shavee;

grant on commit refresh on samqa.bank_accounts to shavee;

grant query rewrite on samqa.bank_accounts to shavee;

grant debug on samqa.bank_accounts to shavee;

grant flashback on samqa.bank_accounts to shavee;




-- sqlcl_snapshot {"hash":"02f573fa5af4aec1878e9b29ae395cdc798affc6","type":"OBJECT_GRANT","name":"object_grants_as_grantor.SAMQA.TABLE.BANK_ACCOUNTS","schemaName":"SAMQA","sxml":""}