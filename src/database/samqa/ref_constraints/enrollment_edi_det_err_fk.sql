alter table samqa.enrollment_edi_detail_error
    add constraint enrollment_edi_det_err_fk
        foreign key ( detail_id )
            references samqa.enrollment_edi_detail ( detail_id )
        enable;


-- sqlcl_snapshot {"hash":"1568dfa920a5e2c171eb323445c36dfe3dcf3f8a","type":"REF_CONSTRAINT","name":"ENROLLMENT_EDI_DET_ERR_FK","schemaName":"SAMQA","sxml":""}