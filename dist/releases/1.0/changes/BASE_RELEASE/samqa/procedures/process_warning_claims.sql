-- liquibase formatted sql
-- changeset SAMQA:1754374145265 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\process_warning_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/process_warning_claims.sql:null:28548139e768f095abc84f0798c9f32ef2fcdc49:create

create or replace procedure samqa.process_warning_claims (
    p_acc_num in varchar2
) as
begin
    for x in (
        select
            *
        from
            claim_interface
        where
                acc_num = p_acc_num
            and interface_status = 'WARNING'
    ) loop
        update claim_interface
        set
            interface_status = 'NOT_INTERFACED'
        where
                acc_num = p_acc_num
            and interface_status = 'WARNING'
            and claim_number = x.claim_number;

        pc_claim.import_uploaded_claims(0, x.batch_number);
        pc_claim.process_uploaded_claims(x.batch_number, 0);
    end loop;
end;
/

