grant alter on samqa.sam_users to asis;

grant delete on samqa.sam_users to rl_sam_rw;

grant delete on samqa.sam_users to asis;

grant index on samqa.sam_users to asis;

grant insert on samqa.sam_users to rl_sam_rw;

grant insert on samqa.sam_users to asis;

grant select on samqa.sam_users to rl_sam1_ro;

grant select on samqa.sam_users to rl_sam_rw;

grant select on samqa.sam_users to rl_sam_ro;

grant select on samqa.sam_users to asis;

grant update on samqa.sam_users to rl_sam_rw;

grant update on samqa.sam_users to asis;

grant references on samqa.sam_users to asis;

grant on commit refresh on samqa.sam_users to asis;

grant query rewrite on samqa.sam_users to asis;

grant debug on samqa.sam_users to asis;

grant flashback on samqa.sam_users to asis;




-- sqlcl_snapshot {"hash":"f0b6381ddc07ef332caa09ef6c3d9f130525e0c1","type":"OBJECT_GRANT","name":"object_grants_as_grantor.SAMQA.TABLE.SAM_USERS","schemaName":"SAMQA","sxml":""}