create or replace editionable trigger samqa.benefit_plan_af after
    insert or delete or update on samqa.ben_plan_enrollment_setup
    for each row
begin
    if deleting then
        pc_utility.insert_notes(:old.ben_plan_id,
                                'BEN_PLAN_ENROLLMENT_SETUP',
                                'Benefit plan has been deleted',
                                get_user_id(v('APP_USER')),
                                sysdate,
                                null,
                                :old.acc_id,
                                :old.entrp_id);
    else
        if :new.note <> :old.note then
            pc_utility.insert_notes(:new.ben_plan_id,
                                    'BEN_PLAN_ENROLLMENT_SETUP',
                                    :new.note,
                                    get_user_id(v('APP_USER')));
        end if;

        if
            :new.acc_id <> :old.acc_id
            and updating
        then
            pc_utility.insert_notes(:new.ben_plan_id,
                                    'BEN_PLAN_ENROLLMENT_SETUP',
                                    'Benefit plan changed from acc_id '
                                    || :old.acc_id
                                    || 'to '
                                    || :new.acc_id,
                                    get_user_id(v('APP_USER')),
                                    sysdate,
                                    null,
                                    :new.acc_id,
                                    :new.entrp_id);

        end if;

        if
            :new.ben_plan_id_main <> :old.ben_plan_id_main
            and updating
        then
            pc_utility.insert_notes(:new.ben_plan_id,
                                    'BEN_PLAN_ENROLLMENT_SETUP',
                                    'Benefit plan changed from ben_plan_id_main '
                                    || :old.ben_plan_id_main
                                    || 'to '
                                    || :new.ben_plan_id_main,
                                    get_user_id(v('APP_USER')),
                                    sysdate,
                                    null,
                                    :new.acc_id,
                                    :new.entrp_id);
        end if;

    end if;

    if updating then
        if
            :old.plan_start_date <> :new.plan_start_date
            or :old.plan_end_date <> :new.plan_end_date
            or :old.runout_period_days <> :new.runout_period_days
            or :old.ben_plan_number <> :new.ben_plan_number
            or :old.ben_plan_name <> :new.ben_plan_name
            or :old.funding_options <> :new.funding_options
            or :old.term_eligibility <> :new.term_eligibility
            or :old.funding_type <> :new.funding_type
            or :old.annual_election <> :new.annual_election
            or :old.effective_date <> :new.effective_date
            or :old.effective_end_date <> :new.effective_end_date
            or :old.minimum_election <> :new.minimum_election
            or :old.maximum_election <> :new.maximum_election
            or :old.grace_period <> :new.grace_period
            or :old.claim_reimbursed_by <> :new.claim_reimbursed_by
            or :old.termination_req_date is null
            and :new.termination_req_date is not null
            or :old.termination_req_date is not null
            and :new.termination_req_date is null
        then
            insert into ben_plan_history (
                ben_plan_id,
                ben_plan_name,
                ben_plan_number,
                plan_start_date,
                plan_end_date,
                status,
                runout_period_days,
                runout_period_term,
                funding_options,
                reimbursement_type,
                reimbursement_ded,
                rollover,
                term_eligibility,
                funding_type,
                acc_id,
                new_hire_contrib,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                note,
                plan_type,
                annual_election,
                claim_reimbursement,
                effective_date,
                effective_end_date,
                minimum_election,
                maximum_election,
                grace_period,
                payroll_contrib,
                created_in_bps,
                entrp_id,
                ben_plan_id_main,
                payroll_frequency,
                fixed_funding_flag,
                batch_number,
                terminated,
                termination_req_date,
                life_event_code,
                division_code,
                transaction_period,
                transaction_limit,
                claim_reimbursed_by,
                reimburse_start_date,
                reimburse_end_date,
                iias_enable,
                external_deductible,
                iias_options,
                sf_ordinance_flag,
                qtly_rprt_start_date,
                appl_all_emp,
                allow_substantiation,
                non_discm_testing,
                plan_docs,
                non_discrm_flag,
                plan_docs_flag,
                renewal_flag,
                renewal_date,
                product_type,
                original_eff_date,
                clm_lang_in_spd,
                subsidy_in_spd_apndx,
                grandfathered,
                self_administered,
                type_of_return,
                is_collective_plan,
                plan_funding_code,
                plan_benefit_code,
                takeover,
                amendment_date,
                welfare_plans_flag,
                plan_term_date,
                fiscal_end_date,
                open_enrollment_start_date,
                open_enrollment_end_date,
                is_cms_opted,
                eob_required,
                is_5500,
                post_tax_flat,
                post_tax_1_1,
                deduct_tax,
                final_filing_flag,
                wrap_plan_5500,
                changed_runout,
                ben_plan_history_id
            ) values ( :old.ben_plan_id,
                       :old.ben_plan_name,
                       :old.ben_plan_number,
                       :old.plan_start_date,
                       :old.plan_end_date,
                       :old.status,
                       :old.runout_period_days,
                       :old.runout_period_term,
                       :old.funding_options,
                       :old.reimbursement_type,
                       :old.reimbursement_ded,
                       :old.rollover,
                       :old.term_eligibility,
                       :old.funding_type,
                       :old.acc_id,
                       :old.new_hire_contrib,
                       :old.creation_date,
                       :old.created_by,
                       :old.last_update_date,
                       :old.last_updated_by,
                       :old.note,
                       :old.plan_type,
                       :old.annual_election,
                       :old.claim_reimbursement,
                       :old.effective_date,
                       :old.effective_end_date,
                       :old.minimum_election,
                       :old.maximum_election,
                       :old.grace_period,
                       :old.payroll_contrib,
                       :old.created_in_bps,
                       :old.entrp_id,
                       :old.ben_plan_id_main,
                       :old.payroll_frequency,
                       :old.fixed_funding_flag,
                       :old.batch_number,
                       :old.terminated,
                       :old.termination_req_date,
                       :old.life_event_code,
                       :old.division_code,
                       :old.transaction_period,
                       :old.transaction_limit,
                       :old.claim_reimbursed_by,
                       :old.reimburse_start_date,
                       :old.reimburse_end_date,
                       :old.iias_enable,
                       :old.external_deductible,
                       :old.iias_options,
                       :old.sf_ordinance_flag,
                       :old.qtly_rprt_start_date,
                       :old.appl_all_emp,
                       :old.allow_substantiation,
                       :old.non_discm_testing,
                       :old.plan_docs,
                       :old.non_discrm_flag,
                       :old.plan_docs_flag,
                       :old.renewal_flag,
                       :old.renewal_date,
                       :old.product_type,
                       :old.original_eff_date,
                       :old.clm_lang_in_spd,
                       :old.subsidy_in_spd_apndx,
                       :old.grandfathered,
                       :old.self_administered,
                       :old.type_of_return,
                       :old.is_collective_plan,
                       :old.plan_funding_code,
                       :old.plan_benefit_code,
                       :old.takeover,
                       :old.amendment_date,
                       :old.welfare_plans_flag,
                       :old.plan_term_date,
                       :old.fiscal_end_date,
                       :old.open_enrollment_start_date,
                       :old.open_enrollment_end_date,
                       :old.is_cms_opted,
                       :old.eob_required,
                       :old.is_5500,
                       :old.post_tax_flat,
                       :old.post_tax_1_1,
                       :old.deduct_tax,
                       :old.final_filing_flag,
                       :old.wrap_plan_5500,
                       :new.runout_period_days,
                       ben_plan_history_seq.nextval );

        end if;

    end if;

end;
/

alter trigger samqa.benefit_plan_af enable;


-- sqlcl_snapshot {"hash":"05ed7e1727d1a4cf634e82079725d878f9fe0114","type":"TRIGGER","name":"BENEFIT_PLAN_AF","schemaName":"SAMQA","sxml":""}