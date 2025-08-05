-- liquibase formatted sql
-- changeset SAMQA:1754374164914 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\benefit_plan_bf.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/benefit_plan_bf.sql:null:2f890865f763f5a81772aac916de4b100bed5163:create

create or replace editionable trigger samqa.benefit_plan_bf before
    insert or update on samqa.ben_plan_enrollment_setup
    for each row
begin
    if inserting then
        :new.created_in_bps := 'N';
    end if;
    if :new.claim_reimbursed_by is null then
        :new.claim_reimbursed_by := 'EMPLOYER';
    end if;

    :new.last_update_date := sysdate;
    :new.claim_reimbursed_by := upper(:new.claim_reimbursed_by);
    :new.plan_term_date := nvl(:new.effective_end_date,
                               :new.plan_end_date) + nvl(:new.runout_period_days,
                                                         0) + nvl(:new.grace_period,
                                                                  0);

    if
        :new.funding_type is null
        and :new.plan_type = 'HRA'
    then
        :new.funding_type := 'PRE_FUND';
    end if;

    if :new.product_type is null then
        :new.product_type := pc_lookups.get_meaning(:new.plan_type,
                                                    'FSA_HRA_PRODUCT_MAP');
    end if;

end;
/

alter trigger samqa.benefit_plan_bf enable;

