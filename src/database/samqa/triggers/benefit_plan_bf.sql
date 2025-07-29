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


-- sqlcl_snapshot {"hash":"a2570ca86d2bc4b276542259282267c439dcaa99","type":"TRIGGER","name":"BENEFIT_PLAN_BF","schemaName":"SAMQA","sxml":""}