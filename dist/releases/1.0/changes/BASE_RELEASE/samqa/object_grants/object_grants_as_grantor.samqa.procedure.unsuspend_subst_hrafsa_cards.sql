-- liquibase formatted sql
-- changeset SAMQA:1754373937254 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.unsuspend_subst_hrafsa_cards.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.unsuspend_subst_hrafsa_cards.sql:null:03548bc3d2408bad902a835edf3decee4c276034:create

grant execute on samqa.unsuspend_subst_hrafsa_cards to rl_sam_ro;

grant execute on samqa.unsuspend_subst_hrafsa_cards to rl_sam_rw;

grant execute on samqa.unsuspend_subst_hrafsa_cards to rl_sam1_ro;

grant debug on samqa.unsuspend_subst_hrafsa_cards to sgali;

grant debug on samqa.unsuspend_subst_hrafsa_cards to rl_sam_rw;

grant debug on samqa.unsuspend_subst_hrafsa_cards to rl_sam1_ro;

