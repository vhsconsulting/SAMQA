-- liquibase formatted sql
-- changeset SAMQA:1754374146978 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\enrollment_edi_det_err_fk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/enrollment_edi_det_err_fk.sql:null:1568dfa920a5e2c171eb323445c36dfe3dcf3f8a:create

alter table samqa.enrollment_edi_detail_error
    add constraint enrollment_edi_det_err_fk
        foreign key ( detail_id )
            references samqa.enrollment_edi_detail ( detail_id )
        enable;

