-- liquibase formatted sql
-- changeset SAMQA:1754374144693 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\populate_er_balance_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/populate_er_balance_gt.sql:null:0da5e53c615c09a88d083ab8d26e0093f879bfcb:create

create or replace procedure samqa.populate_er_balance_gt (
    p_entrp_id in number default null
) is
begin
    insert into er_balance_gt (
        entrp_id,
        product_type
    )
        select distinct
            entrp_id,
            product_type
        from
            ben_plan_enrollment_setup
        where
                entrp_id = p_entrp_id
            and entrp_id is not null
            and plan_end_date > sysdate;

    for x in (
        select
            gt.entrp_id,
            gt.product_type,
            sum(a.check_amount) balance
        from
            employer_balances_v a,
            er_balance_gt       gt
        where
                a.entrp_id = gt.entrp_id
            and a.product_type = gt.product_type
            and gt.product_type <> '0'
            and gt.sam_bal is null
        group by
            gt.entrp_id,
            gt.product_type
    ) loop
        update er_balance_gt
        set
            sam_bal = x.balance
        where
                entrp_id = x.entrp_id
            and product_type = x.product_type;

        commit;
    end loop;

    for x in (
        select
            gt.entrp_id,
            gt.product_type
        from
            er_balance_gt gt
        where
                gt.product_type <> '0'
            and gt.or_bal is null
    ) loop
        for xx in (
            select
                balance
            from
                table ( pc_employer_fin.get_er_balance_report(x.entrp_id, x.product_type, sysdate) )
        ) loop
            update er_balance_gt
            set
                or_bal = xx.balance
            where
                    entrp_id = x.entrp_id
                and product_type = x.product_type;

            commit;
        end loop;
    end loop;

end populate_er_balance_gt;
/

