create or replace package body samqa.pc_web_er_renewal as

    cnt number;

    function get_er_plans (
        p_acc_id in varchar2
    ) return tbl_er_dtl
        pipelined
    is

        rec                    rec_er_dtl;
        v_plan_name            varchar2(4000);
        v_flg_chk              varchar2(1) := 'N';
        l_current_date         date;
        l_creation_date        date;
        ll_count               integer;
        l_plan_renewed_denied  boolean := false;
        l_active_renewal_count integer := 0;
        l_current_year         date;
        l_plan_year            date;
        l_ben_status           varchar2(1);
        v_renewal_deadline     date; -- Added by swamy for Ticket#9384
        v_plan_date            date;      -- Added by swamy for Ticket#9384

    begin
        for i in (
            select
                product_type,
                a.acc_id,
                acc_num,
                plan_type,    -- ben_plan_name,
                account_type, -- added by Jaggi #10729
                a.entrp_id,
                'NO_TRANSIT'         transit,
                max(plan_start_date) start_date,
                max(plan_end_date)   plan_end_date  -- Added by swamy for Ticket#9384
            from
                account                   a,
                ben_plan_enrollment_setup b
            where
                    a.acc_id = p_acc_id
                and a.acc_id = b.acc_id
                and a.entrp_id = b.entrp_id
                and nvl(sf_ordinance_flag, 'N') != 'Y'
                and product_type in ( 'HRA', 'FSA' )
                and account_status = 1
                and status = 'A'
                and plan_type != 'IIR'
                and ( ( ( trunc(plan_end_date) between trunc(sysdate) and trunc(sysdate) + g_prior_days )   -- prior 180 days Ticket Ticket# 7762 Joshi
                        or ( trunc(sysdate) between trunc(plan_end_date) and trunc(plan_end_date) + g_after_days ) ) )  -- after 90 days
                and not exists (
                    select
                        1
                    from
                        account_preference ap
                    where
                            a.acc_id = ap.acc_id
                        and ap.allow_online_renewal = 'N'
                )
                and (
                    select
                        count(*)
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.acc_id = b.acc_id
                        and plan_type in ( 'TRN', 'PKG', 'UA1' )
                        and status = 'A'
                ) = 0
            group by
                product_type,
                a.acc_id,
                acc_num,
                plan_type,
                a.entrp_id,
                account_type --,ben_plan_name
            union
            select
                product_type,
                a.acc_id,
                acc_num,
                plan_type,    --ben_plan_name,
                account_type, -- added by Jaggi #10729
                a.entrp_id,
                'COMBO_TRANSIT'      transit,
                max(plan_start_date) start_date,
                max(plan_end_date)   plan_end_date  -- Added by swamy for Ticket#9384
            from
                account                   a,
                ben_plan_enrollment_setup b
            where
                    a.acc_id = p_acc_id
                and a.acc_id = b.acc_id
                and a.entrp_id = b.entrp_id
                and nvl(sf_ordinance_flag, 'N') != 'Y'
                and product_type in ( 'HRA', 'FSA' )
                and account_status = 1
                and status = 'A'
                and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                and ( ( ( trunc(plan_end_date) between trunc(sysdate) and trunc(sysdate) + g_prior_days )
                        or ( trunc(sysdate) between trunc(plan_end_date) and trunc(plan_end_date) + g_after_days ) ) )
                and (
                    select
                        count(*)
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.acc_id = b.acc_id
                        and plan_type in ( 'TRN', 'PKG', 'UA1' )
                        and status = 'A'
                ) > 0
                and not exists (
                    select
                        1
                    from
                        account_preference ap
                    where
                            a.acc_id = ap.acc_id
                        and ap.allow_online_renewal = 'N'
                )
            group by
                product_type,
                a.acc_id,
                acc_num,
                plan_type,
                a.entrp_id,
                account_type
            union
            select
                product_type,
                a.acc_id,
                acc_num,
                plan_type,    -- ben_plan_name,
                account_type, -- added by Jaggi #10729
                a.entrp_id,
                'COMBO_TRANSIT'      transit,
                max(plan_start_date) start_date,
                max(plan_end_date)   plan_end_date  -- Added by swamy for Ticket#9384
            from
                account                   a,
                ben_plan_enrollment_setup b
            where
                    a.acc_id = p_acc_id
                and a.acc_id = b.acc_id
                and a.entrp_id = b.entrp_id
                and nvl(sf_ordinance_flag, 'N') != 'Y'
                and product_type in ( 'HRA', 'FSA' )
                and account_status = 1
                and status = 'A'
                and plan_type in ( 'TRN', 'PKG', 'UA1' )
                and (
                    select
                        max(plan_start_date)
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.acc_id = b.acc_id
                        and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                ) >= plan_start_date
                and not exists (
                    select
                        1
                    from
                        account_preference ap
                    where
                            a.acc_id = ap.acc_id
                        and ap.allow_online_renewal = 'N'
                )
            group by
                product_type,
                a.acc_id,
                acc_num,
                plan_type,
                a.entrp_id,
                account_type
            union
            select
                product_type,
                a.acc_id,
                acc_num,
                plan_type,    -- ben_plan_name,
                account_type, -- added by Jaggi #10729
                a.entrp_id,
                'STANDALONE_TRANSIT' transit,
                max(plan_start_date) start_date,
                max(plan_end_date)   plan_end_date  -- Added by swamy for Ticket#9384
            from
                account                   a,
                ben_plan_enrollment_setup b
            where
                    a.acc_id = p_acc_id
                and a.acc_id = b.acc_id
                and a.entrp_id = b.entrp_id
                and nvl(sf_ordinance_flag, 'N') != 'Y'
                and product_type = 'FSA'
                and account_status = 1
                and status = 'A'
                and plan_type in ( 'TRN', 'PKG', 'UA1' )
                  --AND MONTHS_BETWEEN(SYSDATE,PLAN_START_DATE)>= 9
                --  AND TRUNC(SYSDATE) < ADD_MONTHS(TO_DATE(TO_CHAR(PLAN_END_DATE,'DD-MON-')||TO_CHAR(SYSDATE,'RRRR'),'DD-MON-YYYY'),2)
                    /*Ticket#7494 . Renewals for Standalone transit plans shud come up between Oct-Mar next yr .The below condition failed if renewal date was Jan-2019*/
                   --AND  ADD_MONTHS(TRUNC(SYSDATE,'YYYY'),12)  BETWEEN TRUNC(SYSDATE)-60 AND TRUNC(SYSDATE)+ 90
                 -- AND TRUNC(SYSDATE) < ADD_MONTHS(TO_DATE(TO_CHAR(PLAN_END_DATE,'DD-MON-')||TO_CHAR(SYSDATE,'RRRR'),'DD-MON-YYYY'),2)
                  --AND TRUNC(SYSDATE) > ADD_MONTHS(TO_DATE(TO_CHAR(PLAN_END_DATE,'DD-MON-')||TO_CHAR(SYSDATE,'RRRR'),'DD-MON-YYYY'),-2)
				  -- Standalone should go -180 and +90 days. Joshi (8036)
                  -- take the YYYY from ben_plan_renewal if TRN is renewaed already.
                    /* commented by Joshi for ticket 12003 
				   AND TO_DATE(TO_CHAR(PLAN_END_DATE,'DD-MON-')|| NVL( ( SELECT TO_CHAR(MAX(END_DATE),'YYYY')
                                                          FROM ben_plan_renewals WHERE ACC_ID = B.ACC_ID
                                                          AND PLAN_TYPE= B.PLAN_TYPE), TO_CHAR(SYSDATE,'YYYY'))
                                                          ,'DD-MON-YYYY') BETWEEN
                    TRUNC(SYSDATE)- G_AFTER_DAYS AND TRUNC(SYSDATE)+ G_PRIOR_DAYS */
                    -- -- Added by Joshi for ticket 12003  
                and pc_web_er_renewal.get_plan_end_date_for_trn_pkg(a.acc_id, b.plan_type) between trunc(sysdate) - g_after_days and trunc
                (sysdate) + g_prior_days   
                  -- FSA  plans should not be up for renewal.
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup d
                    where
                            d.acc_id = b.acc_id
                        and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                        and d.status = 'A'
                )
                                   /*
                                   AND (((TRUNC(D.PLAN_END_DATE) BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE)+ G_PRIOR_DAYS )   -- prior 180 days Ticket Ticket# 7762 Joshi
                                   OR (TRUNC(SYSDATE) BETWEEN TRUNC(D.PLAN_END_DATE) AND TRUNC(D.PLAN_END_DATE) + G_AFTER_DAYS))) )
                                   */
                and not exists (
                    select
                        1
                    from
                        account_preference ap
                    where
                            a.acc_id = ap.acc_id
                        and ap.allow_online_renewal = 'N'
                )
            group by
                product_type,
                a.acc_id,
                acc_num,
                plan_type,
                a.entrp_id,
                account_type
            order by
                1,
                2
        ) loop
            v_flg_chk := 'Y';
            pc_log.log_error('pc_web_er_renewal.get_er_plans', 'I.PLAN_TYPE: ' || i.plan_type);
            select
                nvl(
                    max(ben_plan_id),
                    0
                )
            into rec.ben_plan_id
            from
                ben_plan_enrollment_setup
            where
                    acc_id = i.acc_id
                and plan_type = i.plan_type
                and plan_start_date = nvl(i.start_date, plan_start_date);

            rec.acc_id := i.acc_id;
            rec.acc_num := i.acc_num;
            rec.product_type := i.product_type;
            rec.plan_type := i.plan_type;
            rec.ein := strip_bad(pc_entrp.get_tax_id(i.entrp_id));
            rec.declined := 'N';
            rec.renewed := 'N';
            rec.renewal_date := null;
            rec.declined_date := null;
            rec.renewal_deadline := null;   -- Added by swamy for Ticket#9384
            l_plan_year := null;   -- Added by swamy for Ticket#9384
            v_plan_date := null;   -- Added by swamy for Ticket#9384
            rec.account_type := i.account_type; -- added by Jaggi #10729

            select
                count(*)
            into cnt
            from
                lookups
            where
                    lookup_name = 'FSA_PLAN_TYPE'
                and lookup_code = i.plan_type
                and i.plan_type != 'HRA';

            v_plan_name := null;
            if cnt > 0 then
                for k in (
                    select
                        substr(description, 1, 30) description
                    from
                        lookups
                    where
                            lookup_name = 'FSA_PLAN_TYPE'
                        and lookup_code = i.plan_type
                ) loop
                    v_plan_name := k.description;
                end loop;

                rec.plan_name := v_plan_name;
            else
                for k in (
                    select
                        ben_plan_name
                    from
                        ben_plan_enrollment_setup
                    where
                        ben_plan_id = rec.ben_plan_id
                ) loop
                    v_plan_name := k.ben_plan_name;
                end loop;

                rec.plan_name := nvl(v_plan_name, rec.plan_type);
            end if;

            for k in (
                select
                    creation_date
                from
                    ben_plan_denials
                where
                    ben_plan_id = rec.ben_plan_id
            ) loop
                rec.declined := 'Y';
                rec.declined_date := to_char(k.creation_date, 'MM/DD/YYYY');
            end loop;

            if rec.plan_type not in ( 'TRN', 'PKG', 'UA1' ) then
                for k in (
                    select
                        creation_date
                    from
                        ben_plan_renewals
                    where
                            acc_id = rec.acc_id
                        and renewed_plan_id > rec.ben_plan_id
                        and plan_type = rec.plan_type
                        and end_date > nvl(i.plan_end_date, end_date)  -- Added by Swamy for Ticket#11862 on 15/11/2023
                ) loop
                    rec.renewed := 'Y';
                    rec.renewal_date := to_char(k.creation_date, 'MM/DD/YYYY');
                end loop;
            else
			/* commented by Joshi for 8036.
             FOR K IN ( SELECT MAX(CREATION_DATE) CREATION_DATE
                       FROM  BEN_PLAN_RENEWALS
                      WHERE  ACC_ID= REC.ACC_ID
                      AND    PLAN_TYPE IN  ('TRN','PKG','UA1'))
           LOOP
            IF   k.CREATION_DATE IS NOT NULL
            AND  TO_CHAR(k.CREATION_DATE,'YYYY') = TO_CHAR(SYSDATE,'YYYY') THEN
              REC.RENEWED := 'Y';
              REC.RENEWAL_DATE:= TO_CHAR(k.CREATION_DATE,'MM/DD/YYYY');
            END IF;
           END LOOP;

		   -- Added by Joshi for 8036.  use plan_end_date instead of creation_date for determining
           -- if the plan is already renewed or not.
           ;FOR K IN ( SELECT MAX(END_DATE) END_DATE
                       FROM  BEN_PLAN_RENEWALS
                      WHERE  ACC_ID= REC.ACC_ID
                      AND    PLAN_TYPE IN  ('TRN','PKG','UA1'))
           LOOP
                IF  K.END_DATE IS NOT NULL  THEN
                     l_current_date :=  K.END_DATE ;
                    IF  (  l_current_date    BETWEEN  TRUNC(SYSDATE) AND TRUNC(SYSDATE)+ G_AFTER_DAYS
                        OR TRUNC(SYSDATE) BETWEEN l_current_date AND l_current_date + G_PRIOR_DAYS
                        ) THEN
                        REC.RENEWED := 'Y';
                        REC.RENEWAL_DATE:= TO_CHAR(k.END_DATE,'MM/DD/YYYY');
                    ELSE
                        REC.RENEWED := 'N';
                     END IF;
                END IF;
            END LOOP; 	   */
                l_ben_status := 'N';
                for i in (
                    select
                        'Y'                                          next_yr_status,
                        to_char(ee_plan.creation_date, 'mm/dd/rrrr') creation_date
                    from
                        account           a,
                        ben_plan_renewals ee_plan
                    where
                            a.acc_id = ee_plan.acc_id
                        and ee_plan.acc_id = p_acc_id
                        and ee_plan.end_date > sysdate
                        and ee_plan.plan_type = rec.plan_type -- IN  ('TRN','PKG','UA1')
                        and ee_plan.end_date > (
                            select
                                nvl(
                                    max(br.end_date),
                                    trunc(sysdate)
                                )
                            from
                                ben_plan_renewals br
                            where
                                    br.acc_id = ee_plan.acc_id
                                and br.plan_type = ee_plan.plan_type
                                and ( ( ( trunc(br.end_date) between trunc(sysdate) and trunc(sysdate) + g_prior_days )
                                        or ( trunc(sysdate) between trunc(br.end_date) and trunc(br.end_date) + g_after_days ) ) )
                        )
                ) loop
                    l_ben_status := i.next_yr_status;
                    rec.renewal_date := i.creation_date;
                end loop;

                rec.renewed := nvl(l_ben_status, 'N');
            end if;

            rec.declined := nvl(rec.declined, 'N');
            rec.renewed := nvl(rec.renewed, 'N');
            if rec.plan_type not in ( 'TRN', 'PKG', 'UA1' ) then
                rec.plan_year := null;
                rec.new_plan_year := null;
                for kk in (
                    select
                        plan_start_date,
                        plan_end_date
                    from
                        ben_plan_enrollment_setup
                    where
                        ben_plan_id = rec.ben_plan_id
                ) loop
                    rec.plan_year := to_char(kk.plan_start_date, 'MM/DD/YYYY')
                                     || '-'
                                     || to_char(kk.plan_end_date, 'MM/DD/YYYY');

                    rec.new_plan_year := to_char(
                        add_months(kk.plan_start_date, 12),
                        'MM/DD/YYYY'
                    )
                                         || '-'
                                         || to_char(
                        add_months(kk.plan_end_date, 12),
                        'MM/DD/YYYY'
                    );

                end loop;

            else

           -- Check if all plans are declined. IF yes, consider the trn/pkg plans as a standalone packages.
                if i.transit = 'COMBO_TRANSIT' then
                    select
                        count(*)
                    into l_active_renewal_count
                    from
                        account                   a,
                        ben_plan_enrollment_setup b
                    where
                            a.acc_id = p_acc_id
                        and a.acc_id = b.acc_id
                        and a.entrp_id = b.entrp_id
                        and nvl(sf_ordinance_flag, 'N') != 'Y'
                        and product_type in ( 'HRA', 'FSA' )
                        and account_status = 1
                        and status = 'A'
                        and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                        and ( ( ( trunc(plan_end_date) between trunc(sysdate) and trunc(sysdate) + g_prior_days )
                                or ( trunc(sysdate) between trunc(plan_end_date) and trunc(plan_end_date) + g_after_days ) ) )
                   --GROUP BY PRODUCT_TYPE,A.ACC_ID, ACC_NUM, PLAN_TYPE,A.ENTRP_ID  ;--,ben_plan_name
                        and not exists (
                            select
                                *
                            from
                                ben_plan_denials bd
                            where
                                    bd.acc_id = b.acc_id
                                and bd.ben_plan_id = b.ben_plan_id
                        );

                    if l_active_renewal_count = 0 then
                        i.transit := 'STANDALONE_TRANSIT';
                    end if;
                end if;

                if i.transit = 'STANDALONE_TRANSIT' then
                    rec.plan_year := null;
                    rec.new_plan_year := null;
                    for kk in (
                        select
                            plan_start_date,
                                                --  PLAN_END_DATE , commented and added below code by  by Joshi for 12003 
                            pc_web_er_renewal.get_plan_end_date_for_trn_pkg(acc_id, plan_type) plan_end_date,
                            trunc(creation_date)                                               creation_date
                        from
                            ben_plan_enrollment_setup
                        where
                                ben_plan_id = rec.ben_plan_id
                            and plan_type = rec.plan_type
                    ) loop
                        select
                            max(b.end_date)
                        into l_current_year
                        from
                            ben_plan_renewals b
                        where
                                b.acc_id = rec.acc_id
                            and b.ben_plan_id = rec.ben_plan_id;

                        pc_log.log_error('pc_web_er_renewal.get_er_plans', 'l_current_year: '
                                                                           || l_current_year
                                                                           || ' kk.plan_end_date :='
                                                                           || kk.plan_end_date
                                                                           || ' REC.BEN_PLAN_ID :='
                                                                           || rec.ben_plan_id
                                                                           || ' REC.acc_id :='
                                                                           || rec.acc_id);

                  /* IF l_current_year is not NULL THEN
                      l_plan_year := TO_DATE(to_char(kk.plan_end_date,'DD-MON-')|| TO_CHAR(l_current_year,'YYYY'), 'DD-MON-YYYY');
                   ELSE
                      l_plan_year :=TO_DATE(to_char(kk.plan_end_date,'DD-MON-')|| TO_CHAR(SYSDATE,'YYYY'), 'DD-MON-YYYY') ;
                   END IF;
                   */
                    -- Commented above and fixed below by Swamy for Ticket#12097 20052024
                        l_current_year := nvl(l_current_year, sysdate);

                    -- If the date is 29-feb, we need to take the last day of feb otherwise we get ORA error "date not valid for month specified", bcos next year there may not be 29th feb.
                        if to_char(kk.plan_end_date, 'DD-MON') = '29-FEB' then
                        -- l_plan_year := last_day('01-FEB-'|| TO_CHAR(l_current_year,'YYYY'));
                        -- If the previous year plan is not renewed, then there will not be any record in ben_plan_renewals, so the renewal link will not be populated for the next yyear.
                        -- to avoid that we use kk.plan_end_date.
                            l_plan_year := last_day('01-FEB-'
                                                    || to_char(kk.plan_end_date, 'YYYY'));  -- Commented above and Added by Swamy for Ticket#12411
                        else
                         --l_plan_year := TO_DATE(TO_CHAR(kk.plan_end_date,'DD-MON-')|| TO_CHAR(l_current_year,'YYYY'), 'DD-MON-YYYY');
                        -- If the previous year plan is not renewed, then there will not be any record in ben_plan_renewals, so the renewal link will not be populated for the next yyear.
                        -- to avoid that we use kk.plan_end_date.
                            l_plan_year := kk.plan_end_date;   -- Commented above and Added by Swamy for Ticket#12411
                        end if;

                        pc_log.log_error('pc_web_er_renewal.get_er_plans', 'Standalone transit loop: '
                                                                           || rec.ben_plan_id
                                                                           || rec.plan_type);

                        pc_log.log_error('pc_web_er_renewal.get_er_plans', 'l_plan_year: ' || l_plan_year);

                   --IF l_plan_year BETWEEN  TRUNC(SYSDATE)- G_AFTER_DAYS AND TRUNC(SYSDATE)+ G_PRIOR_DAYS THEN
                        if ( ( ( trunc(l_plan_year) between trunc(sysdate) and trunc(sysdate) + g_prior_days )
                        or ( trunc(sysdate) between trunc(l_plan_year) and trunc(l_plan_year) + g_after_days ) ) ) then
                        -- if the TRN/PKG plans are recently enrolled, they should not be up for renewal.
                            if trunc(sysdate) - trunc(kk.creation_date) < 185 then
                                rec.plan_year := null;
                           -- In order to not to display the renewal deadline below is added
                                v_plan_date := ( trunc(sysdate) - 1 );
                            else
                        /* commented by Joshi for 12003 
                           REC.PLAN_YEAR := TO_CHAR(KK.PLAN_START_DATE,'MM/DD/')||TO_CHAR(SYSDATE,'YYYY')||'-'
                                  ||TO_CHAR(KK.PLAN_END_DATE,'MM/DD/YYYY');
                           REC.NEW_PLAN_YEAR := TO_CHAR(KK.PLAN_START_DATE,'MM/DD/')||TO_CHAR(ADD_MONTHS(SYSDATE,12),'YYYY')
                                            ||'-'||TO_CHAR(KK.PLAN_END_DATE,'MM/DD/YYYY');
                           v_plan_date := (TO_DATE(TO_CHAR(kk.PLAN_END_DATE,'MM/DD/')||TO_CHAR(SYSDATE,'YYYY'),'MM/DD/YYYY'));  -- Added by Swamy for Ticket#9384
                           */
                           -- Added by Joshi for 12003.
                                v_plan_date := kk.plan_end_date;
                                rec.plan_year := to_char(add_months(kk.plan_end_date, -12) + 1,
                                                         'mm/dd/yyyy')
                                                 || '-'
                                                 || to_char(kk.plan_end_date, 'mm/dd/yyyy');

                                rec.new_plan_year := to_char(kk.plan_end_date + 1, 'mm/dd/yyyy')
                                                     || '-'
                                                     || to_char(
                                    add_months(kk.plan_end_date, 12),
                                    'mm/dd/yyyy'
                                );

                            end if;
                        end if;

                    end loop;

                end if;

                if i.transit = 'COMBO_TRANSIT' then
                    rec.plan_year := null;
                    rec.new_plan_year := null;
                    for kk in (
                        select
                            max(plan_start_date) plan_start_date,
                            max(plan_end_date)   plan_end_date
                        from
                            ben_plan_enrollment_setup
                        where
                                acc_id = rec.acc_id
                            and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                        --AND    PLAN_END_DATE <= SYSDATE+90
                        --AND    PLAN_END_DATE <= SYSDATE+ G_AFTER_DAYS   -- AFTER 90 days Joshi #7762
                            and plan_end_date <= sysdate + g_prior_days -- Added by joshi for trn and pkg renewal prod issue 08/28/2019.
                        having
                            max(plan_start_date) >= i.start_date
                    ) loop

			 -- Added by joshi for trn and pkg renewal prod issue 08/28/2019.
                        if kk.plan_end_date between trunc(sysdate) - g_after_days and trunc(sysdate) + g_prior_days then  -- #7762 Joshi

                     -- check if TRN/PKG is renewed atleast once.
                            select
                                count(*)
                            into ll_count
                            from
                                ben_plan_renewals
                            where
                                    acc_id = rec.acc_id
                                and plan_type = rec.plan_type;

                    -- if the TRN/PKG plans are recently enrolled, they should not be up for renewal.

                   -- As per the shavee 185 days should not be checked for COMBO plans.(12436)
                   -- IF LL_COUNT = 0 THEN

                     --   SELECT TRUNC(CREATION_DATE) INTO L_CREATION_DATE
                       --   FROM BEN_PLAN_ENROLLMENT_SETUP
                         --WHERE BEN_PLAN_ID = REC.BEN_PLAN_ID ;

                        --IF TRUNC(SYSDATE) -  L_CREATION_DATE  < 185 THEN
                        --     REC.PLAN_YEAR := NULL;
                              -- In order to not to display the renewal deadline below is added
                         --    v_plan_date := (TRUNC(SYSDATE) - 1);
                       -- ELSE
                        --    REC.PLAN_YEAR := TO_CHAR(KK.PLAN_START_DATE,'MM/DD/YYYY')||'-'||TO_CHAR(KK.PLAN_END_DATE,'MM/DD/YYYY');
                         --   REC.NEW_PLAN_YEAR := TO_CHAR(ADD_MONTHS(KK.PLAN_START_DATE,12),'MM/DD/YYYY')
                        --            ||'-'||TO_CHAR(ADD_MONTHS(KK.PLAN_END_DATE,12),'MM/DD/YYYY');
                           -- v_plan_date := ((kk.PLAN_END_DATE));  -- Added by Swamy for Ticket#9384
                       -- END IF;
                    -- ELSE
                            rec.plan_year := to_char(kk.plan_start_date, 'MM/DD/YYYY')
                                             || '-'
                                             || to_char(kk.plan_end_date, 'MM/DD/YYYY');

                            rec.new_plan_year := to_char(
                                add_months(kk.plan_start_date, 12),
                                'MM/DD/YYYY'
                            )
                                                 || '-'
                                                 || to_char(
                                add_months(kk.plan_end_date, 12),
                                'MM/DD/YYYY'
                            );

                            v_plan_date := ( ( kk.plan_end_date ) );  -- Added by Swamy for Ticket#9384
                     --END IF;
                        end if;
                    end loop;

                end if;

            end if;

         -- Added by Swamy for Ticket#9384
            pc_log.log_error('pc_web_er_renewal.get_er_plans', 'v_plan_date: '
                                                               || v_plan_date
                                                               || ' i.plan_end_date :='
                                                               || i.plan_end_date);

            v_renewal_deadline := nvl(v_plan_date, i.plan_end_date);
            if trunc(sysdate) <= trunc(v_renewal_deadline + 1) then
                rec.renewal_deadline := v_renewal_deadline;
            end if;

            if rec.plan_year is not null then
                pipe row ( rec );
            end if;
        end loop;
    exception
        when others then
            pc_log.log_error('pc_web_er_renewal.get_er_plans', 'others: ' || dbms_utility.format_error_backtrace);
    end get_er_plans;

    function get_plan_dtl (
        p_ben_plan_id in varchar2
    ) return tbl_plan_dtl
        pipelined
    is

        rec                           rec_plan_dtl;
        v_startd                      date;
        v_endt                        date;
        v_plan_type                   rec.plan_type%type;
        v_rollover                    rec.rollover%type;
        v_min_election                rec.min_election%type;
        v_max_election                rec.max_election%type;
        v_grace_period                rec.grace_period%type;
        v_runout_period               rec.runout_period%type;
        v_runout_term                 rec.runout_term%type;
        v_funding_option              rec.funding_option%type;
        v_new_hire_contrb             rec.new_hire_contrb%type;
        v_non_discm_tstng             rec.non_discm_tstng%type;
        v_max_irs                     rec.max_irs%type;
        v_eob_rqrd                    rec.eob_rqrd%type;
        v_dr_card_bal                 rec.dr_card_bal%type;
        v_enrlmnt_start               rec.enrlmnt_start%type;
        v_enrlmnt_end                 rec.enrlmnt_end%type;
        v_product_type                rec.product_type%type;
        v_count_fsa_type              number;
        v_year_tbl                    number;
        v_irs_nxt_yr                  varchar2(500);
        v_irs_lst_yr                  varchar2(500);
        v_startd_new                  varchar2(500);
        v_endt_new1                   varchar2(500);
        v_endt_new                    varchar2(500);
        v_endt_enrl                   rec.enrlmnt_end%type;
        v_trn_cnt                     varchar2(500);
        v_year                        number;
        v_posttax                     varchar2(1);
        v_open_enroll_date            date;
        v_plan_docs                   varchar2(100);--Renewal phase#2
        v_acc_id                      number;
        v_date                        date;  -- Added by Swamy for Ticket#8414
        v_update_limit_match_irs_flag varchar2(1); -- 8237 added for 18/11/2019 rprabu

    begin
        pc_log.log_error('Test', 'Here..Proc');
        for i in (
            select
                plan_type,
                rollover,
                minimum_election,
                maximum_election,
                case
                    when grace_period > 0 then
                        'Y'
                    else
                        'N'
                end                                                  grace_period,
                grace_period                                         grace_days,
                runout_period_days,
                runout_period_term,
                decode(funding_options, '-1', null, funding_options) funding_options,
                decode(new_hire_contrib, 'PRORATE', 'Y', 'N')        new_hire_contrib,
                non_discrm_flag,--NON_DISCM_TESTING,
                       --REPLACE(REPLACE(PC_PARAM.GET_FSA_IRS_LIMIT('TRANSACTION_LIMIT', PLAN_TYPE, SYSDATE),'$'),',')*12,
                       --REPLACE(REPLACE(PC_PARAM.GET_FSA_IRS_LIMIT('TRANSACTION_LIMIT', PLAN_TYPE, SYSDATE),'$'),',') MAX_IRS,
                       --Commented above MAX_IRS and added below as per shavee approval dated on 06/01/2016
                       --REPLACE(REPLACE(PC_PARAM.GET_FSA_IRS_LIMIT('TRANSACTION_LIMIT', PLAN_TYPE, PLAN_END_DATE),'$'),',') MAX_IRS,
                case
                    when plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                         -- commented below and added by Joshi for 12439
                          -- REPLACE(REPLACE(PC_PARAM.GET_FSA_IRS_LIMIT('TRANSACTION_LIMIT', PLAN_TYPE, TO_DATE(TO_CHAR(PLAN_END_DATE,'DD-MON-')||TO_CHAR(SYSDATE,'RRRR'),'DD-MON-RRRR')),'$'),',')
                        replace(
                            replace(
                                pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT',
                                                           plan_type,
                                                           to_date(to_char(plan_start_date, 'DD-MON-')
                                                                   || to_char(sysdate, 'RRRR'),
                                                           'DD-MON-RRRR')),
                                '$'
                            ),
                            ','
                        )
                    else
                            -- REPLACE(REPLACE(PC_PARAM.GET_FSA_IRS_LIMIT('TRANSACTION_LIMIT', PLAN_TYPE, PLAN_END_DATE),'$'),',')
                        replace(
                            replace(
                                pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT', plan_type, plan_start_date),
                                '$'
                            ),
                            ','
                        ) -- commented above and added by Joshi for 12439
                end                                                  max_irs,
                eob_required,
                pc_account.acc_balance_card(acc_id)                  dr_card_bal,
                plan_start_date,
                plan_end_date,
                       --Commented by Karthe for the ticket 2620 on 14/04/2016
                       --TO_CHAR (nvl(OPEN_ENROLLMENT_START_DATE,plan_start_date), 'mm/dd/rrrr') ENROLLMENT_START_DATE,
                       --TO_CHAR (nvl(OPEN_ENROLLMENT_END_DATE,plan_end_date), 'mm/dd/rrrr') ENROLLMENT_END_DATE,
                to_char(open_enrollment_start_date, 'mm/dd/rrrr')    enrollment_start_date,
                to_char(open_enrollment_end_date, 'mm/dd/rrrr')      enrollment_end_date,
                to_char(
                    nvl(open_enrollment_end_date, plan_end_date),
                    'mm/dd/rrrr'
                )                                                    enrollment_end_calc,
                product_type,
                deduct_tax,
                plan_docs, --Added For renewal phase#2
                acc_id,
                update_limit_match_irs_flag    --- --For Renewal Phase#2  --- 8237 added for 18/11/2019 rprabu
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id = p_ben_plan_id
        ) loop
            v_plan_type := i.plan_type;
            v_rollover := i.rollover;
            v_min_election := i.minimum_election;
            v_max_election := i.maximum_election;
            v_grace_period := i.grace_period;
            if i.plan_type not in ( 'TRN', 'PKG', 'UA1' ) then
                rec.grace_days := i.grace_days;
            end if;

            v_runout_period := i.runout_period_days;
            v_runout_term := i.runout_period_term;
            v_funding_option := i.funding_options;
            v_new_hire_contrb := i.new_hire_contrib;
            v_non_discm_tstng := i.non_discrm_flag;
            v_max_irs := i.max_irs;
            v_eob_rqrd := i.eob_required;
            v_dr_card_bal := i.dr_card_bal;
            v_enrlmnt_start := i.enrollment_start_date;
            v_enrlmnt_end := i.enrollment_end_date;
            v_product_type := i.product_type;
            v_startd := i.plan_start_date;
            v_endt := i.plan_end_date;
            v_endt_enrl := i.enrollment_end_calc;
            v_posttax := nvl(i.deduct_tax, 'N');
            v_plan_docs := i.plan_docs;--Renewal phase#2
            v_acc_id := i.acc_id;
            v_update_limit_match_irs_flag := i.update_limit_match_irs_flag;  --- 8237 added for 18/11/2019 rprabu
        end loop;

        pc_log.log_error('V_MAX_IRS := ', '' || v_max_irs);
        rec.plan_type := v_plan_type;
        rec.rollover := v_rollover;
        rec.min_election := v_min_election;
        rec.max_election := v_max_election;
        rec.grace_period := v_grace_period;
        rec.runout_period := v_runout_period;
        rec.runout_term := v_runout_term;
        rec.funding_option := v_funding_option;
        rec.new_hire_contrb := v_new_hire_contrb;
        rec.non_discm_tstng := v_non_discm_tstng;
        rec.max_irs := v_max_irs;
        rec.eob_rqrd := v_eob_rqrd;
        rec.dr_card_bal := v_dr_card_bal;
        rec.enrlmnt_start := v_enrlmnt_start;
        rec.enrlmnt_end := v_enrlmnt_end;
        rec.product_type := v_product_type;
        rec.ben_plan_id := p_ben_plan_id;
        rec.plan_year := to_char(v_startd, 'mm/dd/rrrr')
                         || '-'
                         || to_char(v_endt, 'mm/dd/rrrr');

        rec.post_tax := v_posttax;
        rec.plan_docs := v_plan_docs; --Renewal phase#2
        rec.update_limit_match_irs_flag := nvl(v_update_limit_match_irs_flag, 'N');   --- 8237 added for 18/11/2019 rprabu

        if
            rec.plan_type not in ( 'TRN', 'PKG', 'UA1' )
            and to_char(v_startd, 'rrrr') <= to_char(sysdate, 'rrrr')
        then
         --Added and Condition by Karthe on 16/12/2015 , as per shavee email dated 16/12/2015
            if
                to_char(v_startd, 'mmdd') = '0101'
                and to_char(v_endt, 'mmdd') = '1231'
            then
                rec.new_plan_yr := to_char(
                    add_months(v_startd, 12),
                    'mm/dd/rrrr'
                )
                                   || '-'
                                   || to_char(
                    add_months(v_endt, 12),
                    'mm/dd/rrrr'
                );

            else
            --Commented and added below by Karthe on 10/11/2015 for the short term Plans Year , conversion to 1 year
            --REC.NEW_PLAN_YR :=  TO_CHAR (V_ENDT + 1, 'mm/dd/rrrr') || '-'
                         --       || TO_CHAR (LAST_DAY (V_ENDT + (V_ENDT - V_STARTD) - 1), 'mm/dd/rrrr');
                rec.new_plan_yr := to_char(v_endt + 1, 'mm/dd/rrrr')
                                   || '-'
                                   || to_char(add_months(v_endt + 1, 12) - 1,
                                              'mm/dd/rrrr');
            end if;
        end if;

        if rec.plan_type in ( 'TRN', 'PKG', 'UA1' ) then
         --Commented and Added ALL below by Karthe on 14/11/2015 as Avenelle Mail Dated 14/11/2015
         --REC.NEW_PLAN_YR :=  TO_CHAR (ADD_MONTHS (V_STARTD, 12), 'mm/dd/rrrr')|| '-'||TO_CHAR (V_ENDT, 'mm/dd/rrrr');
         --Start by Karthe on 14/11/2015
            for xx in (
                select
                    *
                from
                    table ( pc_web_er_renewal.get_er_plans(v_acc_id) )
                where
                        declined = 'N'
                    and renewed = 'N'
                    and plan_type = rec.plan_type
            ) loop
                rec.plan_year := xx.plan_year;
                rec.new_plan_yr := xx.new_plan_year;
            end loop;

            select
                count(*)
            into v_count_fsa_type
            from
                ben_plan_renewals
            where
                ben_plan_id = p_ben_plan_id;

            if nvl(v_count_fsa_type, 0) > 0 then
                for i in (
                    select
                        to_char(
                            trunc(end_date),
                            'rrrr'
                        ) end_date
                    from
                        ben_plan_renewals
                    where
                            ben_plan_id = p_ben_plan_id
                        and rownum = 1
                    order by
                        end_date desc
                ) loop
                    v_year_tbl := i.end_date;
                end loop;
            end if;

            if v_endt_enrl is not null then
                if is_date(lpad(v_endt_enrl, 6)
                           || nvl(v_year_tbl,
                                  to_char(sysdate, 'RRRR'))) = 'Y' then
                    v_open_enroll_date := to_date ( lpad(v_endt_enrl, 6)
                                                    || nvl(v_year_tbl,
                                                           to_char(sysdate, 'RRRR')), 'mm/dd/rrrr' );
                else -- for plans ending in 02/29, it is erroring out in non leap year, so we need to subtract a day
                    pc_log.log_error('1', 'Sec if');
                    v_open_enroll_date := to_date ( lpad(
                        to_char(to_date(v_endt_enrl, 'MM/DD/YYYY') - 1, 'MM/DD/YYYY'),
                        6
                    )
                                                    || nvl(v_year_tbl,
                                                           to_char(sysdate, 'RRRR')), 'mm/dd/rrrr' );

                    pc_log.log_error('2', 'Open Enroll.Date' || v_open_enroll_date);
                end if;

                if v_open_enroll_date between trunc(sysdate) and trunc(sysdate) + 90 then
                    v_year := to_char(sysdate, 'rrrr') + 1;
                    v_endt_new1 := '12/31/' || to_char(sysdate, 'rrrr');
                elsif trunc(sysdate) between v_open_enroll_date and trunc(sysdate) + 60 then
                    v_year := to_char(sysdate, 'rrrr');
                    v_endt_new1 := concat('12/31/',
                                          to_char(sysdate, 'rrrr') - 1);
                end if;

            end if;

            v_startd_new := '01/01/' || v_year;
            v_endt_new := '12/31/' || v_year;
         --V_ENDT_NEW1  := '12/31/'||TO_CHAR (SYSDATE, 'rrrr');

--         REC.NEW_PLAN_YR :=  V_STARTD_NEW||'-'||V_ENDT_NEW;
 --        REC.PLAN_YEAR   := TO_CHAR (V_STARTD, 'mm/dd') ||'/'||TO_CHAR (SYSDATE, 'rrrr')|| '-' || V_ENDT_NEW1;

            select
                count(*)
            into v_trn_cnt
            from
                ben_plan_renewals
            where
                ben_plan_id = p_ben_plan_id;

            if nvl(v_trn_cnt, 0) > 0 then
                rec.plan_year := '01/01'
                                 || '/'
                                 || to_char(sysdate, 'rrrr')
                                 || '-'
                                 || v_endt_new1;
            end if;
         --End by Karthe on 14/11/2015
        end if;

        pc_log.log_error('V_ENDT==>' || v_endt, null);
        pc_log.log_error('PLAN_TYPE==>' || rec.plan_type, null);
        pc_log.log_error(1, 'Before ..Found Value');
        if rec.product_type = 'FSA' then
         -- Start Addition by Swamy for Ticket#8414
            if rec.plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                v_date := to_date ( to_char(v_startd, 'DD-MON-')
                                    || to_char(sysdate, 'RRRR'), 'DD-MON-RRRR' );
            else
                v_date := v_startd;
            end if;
         --End of Addition by Swamy for Ticket#8414

            for i in (
                select
                    param_value
                from
                    system_parameters
                where
                        account_type = 'FSA'
                    and plan_type = rec.plan_type
                    and param_code = 'TRANSACTION_LIMIT'
                      --Commented above MAX_IRS and added below as per shavee approval dated on 06/01/2016
                      --AND TO_CHAR(EFFECTIVE_DATE,'RRRR') = TO_CHAR(ADD_MONTHS(SYSDATE,12),'RRRR')
                    and to_char(effective_date, 'RRRR') = to_char(
                        add_months(v_date, 12),
                        'RRRR'
                    )  -- Replaced V_STARTD by V_date by swamy for Ticket#8414
                      --As per ticket 3241, if plan starts in 2016 ,we validare agaist 2016 IRS limits
                order by
                    creation_date
            ) loop
                v_irs_nxt_yr := replace(
                    replace(i.param_value, '$'),
                    ','
                );
            end loop;

            pc_log.log_error(1, 'Found Value' || v_irs_nxt_yr);
            if
                is_number(v_irs_nxt_yr) = 'Y' --AND REC.MAX_ELECTION > TO_NUMBER(V_IRS_NXT_YR)
                and to_number ( v_irs_nxt_yr ) != 0
            then
                pc_log.log_error(1, 'Found Value in loop....' || v_irs_nxt_yr);

          --  REC.MAX_ELECTION_NXT_YR := TO_NUMBER(V_IRS_NXT_YR);
                rec.irs_nxt_yr := to_number ( v_irs_nxt_yr );
            end if;

            pc_log.log_error(1, 'Found Value....' || v_irs_nxt_yr);
            v_irs_lst_yr := rec.max_irs;
            if
                is_number(v_irs_lst_yr) = 'Y' --AND REC.MAX_ELECTION > TO_NUMBER(V_IRS_LST_YR)
                and to_number ( v_irs_lst_yr ) != 0
            then
          --  REC.MAX_ELECTION_LST_YR := TO_NUMBER(V_IRS_LST_YR);
                rec.irs_lst_yr := to_number ( v_irs_lst_yr );
            end if;

        end if;
      /*IF REC.PRODUCT_TYPE = 'FSA' THEN
         FOR I IN (SELECT PARAM_VALUE
                     FROM SYSTEM_PARAMETERS
                    WHERE ACCOUNT_TYPE                   = 'FSA'
                      AND PLAN_TYPE                      = REC.PLAN_TYPE
                      AND TO_CHAR(EFFECTIVE_DATE,'RRRR') = TO_CHAR(SYSDATE,'RRRR')
                    ORDER BY CREATION_DATE) LOOP
             V_MAX_AMOUNT := I.PARAM_VALUE;
         END LOOP;

         IF V_MAX_AMOUNT IS NOT NULL THEN
            V_MAX_AMOUNT := REPLACE(REPLACE(V_MAX_AMOUNT,'$',''),',','');
         END IF;
         DBMS_OUTPUT.PUT_LINE(V_MAX_AMOUNT);
         IF IS_NUMBER(V_MAX_AMOUNT)= 'Y' AND REC.MAX_ELECTION > TO_NUMBER(V_MAX_AMOUNT)  THEN
            REC.MAX_ELECTION := TO_NUMBER(V_MAX_AMOUNT);
         END IF;
         DBMS_OUTPUT.PUT_LINE(REC.MAX_ELECTION);
      END IF;*/
        pc_log.log_error('REC.MAX_IRS := ', '' || rec.max_irs);
        pipe row ( rec );
    end;

    function get_irs_amendment (
        p_plan_strt in varchar2,
        p_plan_endt in varchar2,
        p_plan_type in varchar2
    ) return irs_det_dtl
        pipelined
    is
        rec irs_det_rec;
    begin
        for i in (
            select
                amendment,
                amendment_id,
                to_char(start_date, 'MM/DD/YYYY') start_date,
                to_char(end_date, 'MM/DD/YYYY')   end_date,
                plan_type
            from
                irs_amendments
            where
                    plan_type = p_plan_type
                and ( ( to_date(p_plan_strt, 'MM/DD/YYYY') between start_date and end_date )
                      or ( to_date(p_plan_endt, 'MM/DD/YYYY') between start_date and end_date ) )
                    --AND ((TO_DATE(P_PLAN_STRT, 'MM/DD/YYYY') BETWEEN START_DATE AND END_DATE)
                     --OR  ( START_DATE >= TO_DATE(P_PLAN_STRT, 'MM/DD/YYYY'))))LOOP
                     --and(start_date>= TO_DATE(P_PLAN_STRT, 'MM/DD/YYYY')or
                    /*AND*/--( START_DATE   >= TO_DATE(P_PLAN_STRT, 'MM/DD/YYYY')
                    --AND END_DATE     <= TO_DATE(P_PLAN_ENDT, 'MM/DD/YYYY'))
                    --or END_DATE     <= TO_DATE(P_PLAN_ENDT, 'MM/DD/YYYY')
                    --)*/
        ) loop
            rec.amendment := i.amendment;
            rec.amendment_id := i.amendment_id;
            rec.start_date := i.start_date;
            rec.end_date := i.end_date;
            rec.plan_type := i.plan_type;
            pipe row ( rec );
        end loop;
    end get_irs_amendment;

    function get_irs_docs (
        p_irs_amend_id in number
    ) return irs_doc_rec_t
        pipelined
        deterministic
    is
        l_record_t irs_doc_t;
    begin
        for i in (
            select
                attachment_id,
                document_name,
                document_type,
                attachment
            from
                file_attachments
            where
                    entity_id = p_irs_amend_id
                and entity_name = 'IRS_AMENDMENT'
        ) loop
            l_record_t.doc_id := i.attachment_id;
            l_record_t.doc_name := i.document_name;
            l_record_t.irs_doc := i.attachment;
            l_record_t.irs_doc_ext := i.document_type;
            pipe row ( l_record_t );
        end loop;
    end get_irs_docs;

    function get_coverage (
        p_ben_plan_id varchar2
    ) return tbl_cvrg
        pipelined
    is
        rec rec_cvrg;
    begin
        for i in (
            select
                coverage_id,
                coverage_type,
                annual_election,
                deductible,
                max_rollover_amount
            from
                ben_plan_coverages
            where
                ben_plan_id = p_ben_plan_id
            order by
                coverage_type desc
        ) loop
            rec.coverage_id := i.coverage_id;
            rec.coverage_type := i.coverage_type;
            rec.annual_election := i.annual_election;
            rec.deductible := i.deductible;
            rec.max_rolovr_amt := i.max_rollover_amount;
            pipe row ( rec );
        end loop;
    end;

    procedure insrt_er_ben_plan_enrlmnt (
        p_ben_plan_id                 in varchar2,
        p_min_election                in varchar2 default null,
        p_max_election                in varchar2 default null,
        p_new_plan_yr                 in varchar2,
        p_new_end_plan_yr             in varchar2 default null,     -- Added by Swamy for Ticket#9932 on 07/06/2021
        p_runout_prd                  in varchar2 default null,
        p_runout_trm                  in varchar2 default null,
        p_grace                       in varchar2 default null,
        p_grace_days                  in varchar2 default null,
        p_rollover                    in varchar2 default null,
        p_funding_options             in varchar2 default null,
        p_non_discm                   in varchar2 default null,
        p_new_hire                    in varchar2 default null,
        p_eob_required                in varchar2 default null,
        p_enrlmnt_start               in varchar2 default null,
        p_enrlmnt_endt                in varchar2 default null,
        p_plan_docs                   in varchar2 default null, ----Renewal Phase#2
        p_user_id                     in varchar2,
        p_post_tax                    in varchar2 default null,
        p_pay_acct_fees               in varchar2,--Renewal phase#2
        p_update_limit_match_irs_flag varchar2 default null,  --- 8237 18/11/2019  rprabu
        p_source                      in varchar2 default 'ONLINE', --- 8633 02/20/2020
        p_batch_number                in number,    -- Added by Swamy for Ticket#10431(Renewal Resubmit)
        p_new_ben_pln_id              in out varchar2,  -- Modified from OUT to IN OUT by Swamy for Ticket#10431(Renewal Resubmit)
        x_return_status               out varchar2,
        x_error_message               out varchar2
    ) is

        row_set               ben_plan_enrollment_setup%rowtype;
        row_cvg               ben_plan_coverages%rowtype;
        l_notify_flg          varchar2(1) := 'N';
        l_ben_plan_new        varchar2(300);
        l_acc_id              number;
        l_ben_plan_id_new     number;
        l_ben_plan_id_not     number;
        l_ben_plan_end_date   date;
        cnt1                  number;
        l_cnt2                number;
        l_entrp_id            varchar2(100);
        l_acc_num             varchar2(100);
        l_plan_type           varchar2(100);
        l_email_flg           varchar2(1);
        l_count_hra_new       number;
        l_count_hra           number;
        l_end_date            date;
        l_enrlmnt_start       date;
        l_enrlmnt_endt        date;
        l_fsa_count           integer;
        l_plan_start_date     date;
        l_plan_end_date       date;
        l_new_plan_start_date date;
        l_new_plan_end_date   date;
        l_fsa_start_date      date;
        l_fsa_end_date        date;
        l_max_plan_start_date date;
        l_max_plan_end_date   date;
        v_account_type        account.account_type%type;  -- Added by Swamy for Ticket#8684
        v_resubmit_flag       varchar2(1); -- Added by Swamy for Ticket#10431(Renewal Resubmit)
        l_account_type        account.account_type%type;
        l_user_id             number; -- added by Jaggi #11368
    begin
        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'P_BEN_PLAN_ID' || p_ben_plan_id);
        select
            count(*)
        into cnt
        from
            ben_plan_enrollment_setup
        where
            ben_plan_id = p_ben_plan_id;

        dbms_output.put_line(cnt);
        if cnt > 0 then
         /*SELECT PLAN_TYPE
           INTO L_PLAN_TYPE
           FROM BEN_PLAN_ENROLLMENT_SETUP
          WHERE BEN_PLAN_ID = P_BEN_PLAN_ID;*/

            for j in (
                select
                    b.plan_type,
                    b.acc_id,
                    a.account_type
                from
                    ben_plan_enrollment_setup b,
                    account                   a
                where
                        a.acc_id = b.acc_id
                    and ben_plan_id = p_ben_plan_id
            ) loop
                l_plan_type := j.plan_type;
                l_acc_id := j.acc_id;
                l_account_type := j.account_type;
            end loop;
        end if;

        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'P_POST_TAX'
                                                      || p_post_tax
                                                      || 'CNT :='
                                                      || cnt
                                                      || 'L_PLAN_TYPE :='
                                                      || l_plan_type
                                                      || 'P_BEN_PLAN_ID :='
                                                      || p_ben_plan_id);

        if
            cnt > 0
            and l_plan_type in ( 'TRN', 'PKG', 'UA1' )
            and p_ben_plan_id is not null
        then--NEW_PLAN_YR IS NOT NULL THEN

            -- Code added by Joshi for #8036 (changing the plan start and plan end date of TRN/PKG/UA1 renewals inline with FSA/HRA.)
            select
                acc_id
            into l_acc_id
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id = p_ben_plan_id;

            select
                count(b.ben_plan_id)
            into l_fsa_count
            from
                account                   a,
                ben_plan_enrollment_setup b
            where
                    a.acc_id = l_acc_id
                and a.entrp_id = b.entrp_id
                and b.plan_type in ( 'HRA', 'FSA' )
                and status = 'A';
               -- commented below and added above for  ticket:12436 Joshi
               /*AND NOT EXISTS ( SELECT * FROM BEN_PLAN_ENROLLMENt_SETUP D
                                   WHERE d.acc_id= b.acc_id
                                     AND PLAN_TYPE   IN ('TRN','PKG','UA1')
                                     AND STATUS = 'A') ;*/

            select
                plan_start_date,
                plan_end_date
            into
                l_plan_start_date,
                l_plan_end_date
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id = p_ben_plan_id;

            pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'l_FSA_COUNT' || l_fsa_count);

            -- for standalone plan, if the plan end date is 2099, plan start date with 01/01 otherise take the plan start date
            -- from same plan and bring it to current year.
            if l_fsa_count = 0 then
                for xx in (
                    select
                        max(start_date) start_date,
                        max(end_date)   end_date
                    from
                        ben_plan_renewals
                    where
                        ben_plan_id = p_ben_plan_id
                ) loop
                    l_new_plan_start_date := xx.end_date + 1;
                    l_new_plan_end_date := add_months(l_new_plan_start_date, 12) - 1;
                end loop;

                pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'P_BEN_PLAN_ID' || p_ben_plan_id);
                if l_new_plan_start_date is null then
                    if to_char(l_plan_end_date, 'YYYY') = '2099' then
                         /* commented by Joshi for  12003/12027
                        IF SYSDATE <=  TO_DATE('31-DEC-' ||TO_CHAR(SYSDATE, 'YYYY'), 'DD-MON-YYYY') THEN
                            L_NEW_PLAN_START_DATE := TO_DATE('12/31/' ||TO_CHAR(SYSDATE, 'YYYY'), 'MM/DD/YYYY') + 1;
                            L_NEW_PLAN_END_DATE   := ADD_MONTHS(L_NEW_PLAN_START_DATE,12)-1;
                        ELSE
                            L_NEW_PLAN_START_DATE :=  TRUNC(SYSDATE,'YYYY');
                            L_NEW_PLAN_END_DATE   := ADD_MONTHS(L_NEW_PLAN_START_DATE,12)-1;
                        END IF; */

                         -- Added by Joshi for ticket 12003/12027  
                        select
                            plan_start_date,
                            pc_web_er_renewal.get_plan_end_date_for_trn_pkg(acc_id, plan_type) plan_end_date
                        into
                            l_plan_start_date,
                            l_plan_end_date
                        from
                            ben_plan_enrollment_setup
                        where
                            ben_plan_id = p_ben_plan_id;

                        l_new_plan_start_date := l_plan_end_date + 1;
                        l_new_plan_end_date := add_months(l_new_plan_start_date, 12) - 1;
                    else
                        l_new_plan_start_date := l_plan_end_date + 1;    -- TO_CHAR(L_PLAN_START_DATE,'DD-MON') || '-' || TO_CHAR(SYSDATE,'YYYY');
                        l_new_plan_end_date := add_months(l_new_plan_start_date, 12) - 1;
                    end if;
                end if;

            end if;

            if l_fsa_count > 0 then
                select
                    max(plan_start_date),
                    max(plan_end_date)
                into
                    l_fsa_start_date,
                    l_fsa_end_date
                from
                    account                   a,
                    ben_plan_enrollment_setup b
                where
                        a.acc_id = b.acc_id
                    and a.entrp_id = b.entrp_id
                    and nvl(sf_ordinance_flag, 'N') != 'Y'
                    and product_type in ( 'HRA', 'FSA' )
                    and account_status = 1
                    and status = 'A'
                    and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                    and b.acc_id = (
                        select
                            acc_id
                        from
                            ben_plan_enrollment_setup
                        where
                            ben_plan_id = p_ben_plan_id
                    );

                    --IF there exist FSA/HRA plans along with TRN then if TRN/PKG/UA1 plan end date is 2099 then take plan start date
                    -- from FSA/HRA plan else take the existing TRN/PKG Planstart date and bring it to currnet year.
                if to_char(l_plan_end_date, 'YYYY') = '2099' then
                    l_new_plan_start_date := l_fsa_start_date;  -- TO_CHAR(L_FSA_START_DATE,'DD-MON') || '-' || TO_CHAR(SYSDATE,'YYYY');   ticket:12436
                    l_new_plan_end_date := l_fsa_end_date; --  DD_MONTHS(L_NEW_PLAN_START_DATE,12)-1;    ticket: 12436
                else
                    l_new_plan_start_date := to_char(l_plan_start_date, 'DD-MON')
                                             || '-'
                                             || to_char(sysdate, 'YYYY');

                    l_new_plan_end_date := add_months(l_new_plan_start_date, 12) - 1;
                end if;

            end if;
        -- Code ends here Joshi #8036.
            pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments l_pay_acct_fees number', p_pay_acct_fees);
            insert into ben_plan_renewals (
                acc_id,
                ben_plan_id,
                plan_type,
                creation_date,
                created_by,
                start_date,
                end_date,
                last_updated_date,
                last_updated_by,
                renewed_plan_id,
                pay_acct_fees,
                source,
                renewal_batch_number   -- Added by Swamy for Ticket#1119
            )
                select
                    acc_id,
                    ben_plan_id,
                    plan_type,--PLAN_TYPE,
                    sysdate,
                    p_user_id,
                    l_new_plan_start_date,   --TRUNC(SYSDATE,'YYYY'),
                    l_new_plan_end_date,    --ADD_MONTHS(TRUNC(SYSDATE,'YYYY'),12)-1,
                    sysdate,
                    p_user_id,
                    ben_plan_id,
                    upper(p_pay_acct_fees),  -- Added by jaggi #11119
                    p_source,     -- 'ONLINE' commented by Joshi 8633.
                    p_batch_number   -- Added by Swamy for Ticket#1119
                from
                    ben_plan_enrollment_setup
                where
                    ben_plan_id = p_ben_plan_id;

            update ben_plan_enrollment_setup
            set
                deduct_tax = nvl(p_post_tax, 'N'),
                update_limit_match_irs_flag = p_update_limit_match_irs_flag  --- 8237 18/11/2019  rprabu
            where
                ben_plan_id = p_ben_plan_id;

            p_new_ben_pln_id := p_ben_plan_id;   -- Added by Swamy for Ticket#10751
             --  Start Added by swamy for ticket#10747
            l_acc_num := pc_account.get_acc_num_from_acc_id(l_acc_id);
            l_entrp_id := pc_entrp.get_entrp_id(l_acc_num);
               -- Send notification to Broker
            pc_notifications.notify_broker_ren_decl_plan(
                p_acc_id       => l_acc_id,
                p_user_id      => p_user_id,
                p_entrp_id     => l_entrp_id,
                p_ben_pln_name =>
                                case
                                    when pc_account.get_account_type(l_acc_id) = 'ERISA_WRAP' then
                                        pc_lookups.get_meaning(l_plan_type, 'PLAN_TYPE_WRAP')
                                    else
                                        l_plan_type
                                end,
                p_ren_dec_flg  => 'R',
                p_acc_num      => l_acc_num
            );

               -- Send notification to Employer
            pc_notifications.notify_er_ren_decl_plan(
                p_acc_id       => l_acc_id,
                p_ename        => pc_entrp.get_entrp_name(l_entrp_id),
                p_email        => pc_users.get_email_from_user_id(p_user_id),
                p_user_id      => p_user_id,
                p_entrp_id     => l_entrp_id,
                p_ben_plan_id  => l_ben_plan_id_new,
                p_ben_pln_name =>
                                case
                                    when pc_account.get_account_type(l_acc_id) = 'ERISA_WRAP' then
                                        pc_lookups.get_meaning(l_plan_type, 'PLAN_TYPE_WRAP')
                                    else
                                        l_plan_type
                                end,
                p_ren_dec_flg  => 'R',
                p_acc_num      => l_acc_num
            );

        end if;

        if
            cnt > 0
            and l_plan_type not in ( 'TRN', 'PKG', 'UA1' )
            and p_ben_plan_id is not null
        then--NEW_PLAN_YR IS NOT NULL THEN
            begin
                select
                    *
                into row_set
                from
                    ben_plan_enrollment_setup
                where
                        ben_plan_id = p_ben_plan_id
                    and rownum = 1;

            exception
                when others then
                    x_error_message := sqlerrm
                                       || ' '
                                       || 'in Getting rows of Plan setup';
                    x_return_status := 'E';
            end;

            v_resubmit_flag := pc_account.get_renewal_resubmit_flag(row_set.entrp_id);    -- Added by Swamy for Ticket#10431

            if nvl(v_resubmit_flag, 'N') = 'N' then   -- Added by Swamy for Ticket#10431
                row_set.plan_start_date := to_date ( lpad(p_new_plan_yr, 10), 'mm/dd/rrrr' );
            end if;

            select
                count(*)
            into cnt1
            from
                ben_plan_enrollment_setup
            where
                    acc_id = row_set.acc_id
                and plan_type = row_set.plan_type
                and plan_start_date >= row_set.plan_start_date
                and ( ( status = 'A'
                        and product_type in ( 'HRA', 'FSA' ) )
                      or ( nvl(product_type, '*') not in ( 'HRA', 'FSA' ) ) );  -- Added by Swamy for Ticket#10431(Renewal Resubmit), for erisa product type is comming as null

            dbms_output.put_line(row_set.acc_id
                                 || ' '
                                 || row_set.plan_type
                                 || ' '
                                 || row_set.plan_start_date
                                 || cnt1);

            v_account_type := pc_account.get_account_type(row_set.acc_id);    -- Added by Swamy for Ticket#8684
            pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'CNT1..'
                                                          || cnt1
                                                          || ' ROW_SET.PLAN_TYPE :='
                                                          || row_set.plan_type
                                                          || ' ROW_SET.PLAN_START_DATE :='
                                                          || row_set.plan_start_date
                                                          || ' v_resubmit_flag :='
                                                          || v_resubmit_flag);

            if cnt1 = 0 then
                l_ben_plan_id_new := ben_plan_seq.nextval;
			--ROW_SET.PLAN_END_DATE              := TO_DATE (SUBSTR (P_NEW_PLAN_YR, -10), 'mm/dd/rrrr');
            -- Commented above and added below by Swamy for Ticket#8684 on 19/05/2020
                if v_account_type = 'ERISA_WRAP' then
               --ROW_SET.PLAN_END_DATE   := ADD_MONTHS(ROW_SET.PLAN_START_DATE,12)-1;     -- Commented by Swamy for Ticket# on 07/06/2021
                    row_set.plan_end_date := to_date ( lpad(p_new_end_plan_yr, 10), 'mm/dd/rrrr' );   -- Added by Swamy for Ticket# on 07/06/2021
                    row_set.effective_date := row_set.plan_start_date;
                else
                    row_set.plan_end_date := to_date ( substr(p_new_plan_yr, -10), 'mm/dd/rrrr' );
                end if;

                row_set.ben_plan_id := l_ben_plan_id_new;
                p_new_ben_pln_id := l_ben_plan_id_new;--BEN_PLAN_SEQ.CURRVAL;
                row_set.batch_number := p_batch_number;  -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                row_set.minimum_election := p_min_election;
                row_set.maximum_election := p_max_election;
                row_set.renewal_flag := 'Y';
                row_set.runout_period_days := p_runout_prd;
                pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'Here..' || '1');
                row_set.runout_period_term := p_runout_trm;
                row_set.grace_period :=
                    case
                        when p_grace = 'Y' then
                            p_grace_days/*ROW_SET.GRACE_PERIOD*/
                        else 0
                    end;
                row_set.rollover := p_rollover;
                row_set.funding_options := p_funding_options;
                row_set.non_discrm_flag := p_non_discm;
                row_set.new_hire_contrib :=
                    case
                        when p_new_hire = 'Y' then
                            'PRORATE'
                        else 'N'
                    end;
                row_set.eob_required := p_eob_required;
          --  ROW_SET.OPEN_ENROLLMENT_START_DATE := TO_DATE (P_ENRLMNT_START,'mm/dd/rrrr');
          --  ROW_SET.OPEN_ENROLLMENT_END_DATE   := TO_DATE (P_ENRLMNT_ENDT, 'mm/dd/rrrr');
          /* renewal Phase#2*/
                row_set.open_enrollment_start_date := to_date ( p_enrlmnt_start, 'dd-mon-rrrr' );
                row_set.open_enrollment_end_date := to_date ( p_enrlmnt_endt, 'dd-mon-rrrr' );
                row_set.renewal_date := sysdate;
                row_set.creation_date := sysdate;
                row_set.created_by := p_user_id;
                row_set.last_update_date := null;
                row_set.last_updated_by := null;
                row_set.amendment_date := null;
                row_set.plan_docs_flag := p_plan_docs; --Renewal Phase#2
                row_set.deduct_tax := nvl(p_post_tax, 'N'); --Added by Karthe for the IRS development for TRN, PKG, UA1
                row_set.update_limit_match_irs_flag := p_update_limit_match_irs_flag;  --- 8237 18/11/2019  rprabu
                select
                    count(*)
                into cnt
                from
                    account
                where
                        acc_id = row_set.acc_id
                    and account_type = 'ERISA_WRAP';

                if cnt > 0 then
                    row_set.plan_type := 'RENEW';
                end if;

            -- INSERT INTO BEN_PLAN_ENROLLMENT_SETUP VALUES ROW_SET returning plan_end_date into l_end_date;
             --  commented above and Added below  by Joshi for 9678
                if nvl(p_source, 'ONLINE') = 'ONLINE' then
                    insert into ben_plan_enrollment_setup values row_set returning plan_end_date into l_end_date;

                end if;


            -- Added by Joshi for 9678
            -- (when renewed from SAM, the plan should not be inserted in ben_plan_ebrollment_setup)
                if p_source = 'ONLINE' then
                    l_new_plan_start_date := row_set.plan_start_date;
                    l_new_plan_end_date := l_end_date;
                else
                    for p in (
                        select
                            ben_plan_id,
                            plan_start_date,
                            plan_end_date
                        from
                            ben_plan_enrollment_setup
                        where
                                plan_type = case
                                                when l_account_type in ( 'HRA', 'FSA' ) then
                                                    l_plan_type
                                                else
                                                    plan_type
                                            end
                            and acc_id = l_acc_id
                            and status = case
                                             when l_account_type = 'FORM_5500' then
                                                 'P'
                                             else
                                                 'A'
                                         end
                            and ben_plan_id > p_ben_plan_id
                    ) loop
                        l_new_plan_start_date := p.plan_start_date;
                        l_new_plan_end_date := p.plan_end_date;
                        l_ben_plan_id_new := p.ben_plan_id;
                        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'L_NEW_PLAN_START_DATE Email' || l_new_plan_start_date);
                        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'L_NEW_PLAN_END_DATE' || l_new_plan_end_date);
                        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'L_BEN_PlAN_ID_NEWl' || l_ben_plan_id_new);
                    end loop;
                end if;
           -- Code ends here joshi for 9678.

            -- AND P_NEW_BEN_PLN_ID is null Cond. Added by Swamy for Ticket#10431(Renewal Resubmit)
			-- for resubmit no record shoud be inserted into ben_plan_renewals..the record is already getting updated in the above procedure
			-- IF SQL%ROWCOUNT > 0 AND  P_BEN_PLAN_ID IS NOT NULL AND NVL(v_resubmit_flag,'N') = 'N' THEN --AND L_PLAN_TYPE IN('TRN','PKG','UA1')--NEW_PLAN_YR IS NULL THEN

                pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'P_BEN_PLAN_ID..' || p_ben_plan_id);
                if
                    p_ben_plan_id is not null
                    and nvl(v_resubmit_flag, 'N') = 'N'
                then
                    insert into ben_plan_renewals (
                        acc_id,
                        ben_plan_id,
                        plan_type,
                        creation_date,
                        created_by,
                        start_date,
                        end_date,
                        last_updated_date,
                        last_updated_by,
                        renewed_plan_id,
                        pay_acct_fees,
                        renewal_batch_number,   -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                        source
                    )--Renewal phase#2
                        select
                            acc_id,
                            p_ben_plan_id,
                            case
                                when pc_account.get_account_type(acc_id) = 'ERISA_WRAP' then
                                    'ERISA_WRAP'
                                else
                                    plan_type
                            end,--PLAN_TYPE,
                            sysdate,
                            p_user_id,
                            l_new_plan_start_date, -- 9678  --row_set.plan_start_date,--nvl(TO_DATE(P_ENRLMNT_START,'mm/dd/rrrr'),row_set.plan_start_date),
                            l_new_plan_end_date,   -- 9678 --l_end_date,--nvl(TO_DATE(P_ENRLMNT_ENDT,'mm/dd/rrrr'),l_end_date),
                            sysdate,
                            p_user_id,
                            l_ben_plan_id_new,
                            upper(p_pay_acct_fees),
                            p_batch_number,   -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                            p_source    -- added by Joshi for 9678
                                -- renewal phase#2
                        from
                            ben_plan_enrollment_setup
                        where
                            ben_plan_id = l_ben_plan_id_new;

                    pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'After Insert..Renewal' || sql%rowcount);
                    for i in (
                        select
                            acc_id,
                            ben_plan_id,
                            plan_type
                        from
                            ben_plan_renewals
                        where
                                renewed_plan_id = l_ben_plan_id_new
                            and to_char(creation_date, 'RRRR') = to_char(sysdate, 'RRRR')
                            and nvl(source, 'ONLINE') = 'ONLINE'
                    ) loop
                        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'Before Email' || l_ben_plan_id_new);
                        l_ben_plan_new := nvl(
                            pc_lookups.get_meaning('FSA_PLAN_TYPE', i.plan_type),
                            i.plan_type
                        );

                        l_acc_id := i.acc_id;
                        l_acc_num := pc_account.get_acc_num_from_acc_id(l_acc_id);
                        l_entrp_id := pc_entrp.get_entrp_id(l_acc_num);
                        l_ben_plan_id_not := p_ben_plan_id;

               -- Start Added by swamy for ticket#10747
               -- Send notification to the Broker
                        pc_notifications.notify_broker_ren_decl_plan(
                            p_acc_id       => l_acc_id,
                            p_user_id      => p_user_id,
                            p_entrp_id     => l_entrp_id,
                            p_ben_pln_name =>
                                            case
                                                when pc_account.get_account_type(l_acc_id) = 'ERISA_WRAP' then
                                                    pc_lookups.get_meaning(l_plan_type, 'PLAN_TYPE_WRAP')
                                                else
                                                    l_plan_type
                                            end,
                            p_ren_dec_flg  => 'R',
                            p_acc_num      => l_acc_num
                        );

                        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'Before Email L_ACC_ID' || l_acc_id);
                        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'Before Email L_BEN_PLAN_NEW' || l_ben_plan_new);
                        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'Before Email L_ACC_NUM' || l_acc_num);
                        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'Before Email L_BEN_PLAN_ID_NEW' || l_ben_plan_id_new);
                        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'Before Email ROW_SET.PRODUCT_TYPE' || row_set.product_type);
                        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'Before Email P_USER_ID' || p_user_id);
                        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'Before Email L_ENTRP_ID' || l_entrp_id);

              -- Added by Jaggi #11368
                        for j in (
                            select
                                renewed_by,
                                renewed_by_id,
                                renewal_sign_type,
                                renewed_by_user_id
                            from
                                table ( pc_employer_enroll_compliance.get_employer_details(l_entrp_id,
                                                                                           pc_account.get_account_type(l_acc_id),
                                                                                           'RENEWAL') )
                        ) loop
                            if j.renewed_by = 'BROKER' then
                                for z in (
                                    select
                                        a.user_id
                                    from
                                        online_users a,
                                        broker       b
                                    where
                                            upper(a.find_key) = upper(b.broker_lic)
                                        and b.broker_id = j.renewed_by_id
                                        and a.user_id = j.renewed_by_user_id
                                ) loop
                                    l_user_id := z.user_id;
                     -- Send notification to the Broker
                                    pc_notifications.notify_broker_hra_fsa_plan_renew(
                                        p_acc_id       => l_acc_id,
                                        p_plan_type    => l_ben_plan_new,
                                        p_acc_num      => l_acc_num,
                                        p_ben_plan_id  => l_ben_plan_id_new,
                                        p_product_type => row_set.product_type,
                                        p_user_id      => l_user_id,
                                        p_entrp_id     => l_entrp_id
                                    );

                                    if p_user_id <> l_user_id then
                                        pc_notifications.notify_broker_ren_decl_plan(
                                            p_acc_id       => l_acc_id,
                                            p_user_id      => l_user_id,
                                            p_entrp_id     => l_entrp_id,
                                            p_ben_pln_name =>
                                                            case
                                                                when pc_account.get_account_type(l_acc_id) = 'ERISA_WRAP' then
                                                                    pc_lookups.get_meaning(l_plan_type, 'PLAN_TYPE_WRAP')
                                                                else
                                                                    l_plan_type
                                                            end,
                                            p_ren_dec_flg  => 'R',
                                            p_acc_num      => l_acc_num
                                        );
                                    end if;

                                end loop;

                            elsif j.renewed_by = 'GA' then
                                for z in (
                                    select
                                        a.user_id
                                    from
                                        online_users  a,
                                        general_agent g
                                    where
                                            upper(a.find_key) = upper(g.ga_lic)
                                        and g.ga_id = j.renewed_by_id
                                        and a.user_id = j.renewed_by_user_id
                                ) loop
                                    l_user_id := z.user_id;
                     -- Send notification to the Broker
                                    pc_notifications.notify_ga_hra_fsa_plan_renew(
                                        p_acc_id       => l_acc_id,
                                        p_plan_type    => l_ben_plan_new,
                                        p_acc_num      => l_acc_num,
                                        p_ben_plan_id  => l_ben_plan_id_new,
                                        p_product_type => row_set.product_type,
                                        p_user_id      => l_user_id,
                                        p_entrp_id     => l_entrp_id
                                    );

                                    pc_notifications.notify_ga_ren_decl_plan(
                                        p_acc_id       => l_acc_id,
                                        p_user_id      => l_user_id,
                                        p_entrp_id     => l_entrp_id,
                                        p_ben_pln_name =>
                                                        case
                                                            when pc_account.get_account_type(l_acc_id) = 'ERISA_WRAP' then
                                                                pc_lookups.get_meaning(l_plan_type, 'PLAN_TYPE_WRAP')
                                                            else
                                                                l_plan_type
                                                        end,
                                        p_ren_dec_flg  => 'R',
                                        p_acc_num      => l_acc_num
                                    );

                                end loop;
                            else 
                 -- Send notification to the Broker
                                pc_notifications.notify_broker_hra_fsa_plan_renew(
                                    p_acc_id       => l_acc_id,
                                    p_plan_type    => l_ben_plan_new,
                                    p_acc_num      => l_acc_num,
                                    p_ben_plan_id  => l_ben_plan_id_new,
                                    p_product_type => row_set.product_type,
                                    p_user_id      => p_user_id,
                                    p_entrp_id     => l_entrp_id
                                );
                            end if;
                        end loop;

                        pc_notifications.notify_er_ren_decl_plan(
                            p_acc_id       => l_acc_id,
                            p_ename        => pc_entrp.get_entrp_name(l_entrp_id),
                            p_email        => pc_users.get_email_from_user_id(p_user_id),
                            p_user_id      => p_user_id,
                            p_entrp_id     => l_entrp_id,
                            p_ben_plan_id  => l_ben_plan_id_new,--P_BEN_PLN_NAME => L_PLAN_TYPE,
                            p_ben_pln_name =>
                                            case
                                                when pc_account.get_account_type(l_acc_id) = 'ERISA_WRAP' then
                                                    pc_lookups.get_meaning(l_plan_type, 'PLAN_TYPE_WRAP')
                                                else
                                                    l_plan_type
                                            end,
                            p_ren_dec_flg  => 'R',
                            p_acc_num      => l_acc_num
                        );

                        pc_notifications.notify_er_hra_fsa_plan_renew(
                            p_acc_id       => l_acc_id,
                            p_plan_type    => l_ben_plan_new,
                            p_acc_num      => l_acc_num,
                            p_ben_plan_id  => l_ben_plan_id_new,
                            p_product_type => row_set.product_type,--'FSA',
                            p_user_id      => p_user_id,
                            p_entrp_id     => l_entrp_id
                        );

                    end loop;

              /*IF PC_LOOKUPS.GET_meaning(ROW_SET.PLAN_TYPE,'FSA_HRA_PRODUCT_MAP') = 'HRA'  THEN
                  INSERT INTO BEN_PLAN_COVERAGES (COVERAGE_ID,
                                                  BEN_PLAN_ID,
                                                  ACC_ID,
                                                  COVERAGE_TYPE,
                                                  DEDUCTIBLE,
                                                  START_DATE,
                                                  END_DATE,
                                                  FIXED_FUNDING_AMOUNT,
                                                  ANNUAL_ELECTION,
                                                  FIXED_FUNDING_FLAG,
                                                  DEDUCTIBLE_RULE_ID,
                                                  COVERAGE_TIER_NAME,
                                                  MAX_ROLLOVER_AMOUNT,
                                                  CREATION_DATE,
                                                  CREATED_BY,
                                                  LAST_UPDATE_DATE,
                                                  LAST_UPDATED_BY)
                     SELECT COVERAGE_SEQ.NEXTVAL,
                            P_NEW_BEN_PLN_ID,
                            ACC_ID,
                            COVERAGE_TYPE,
                            DEDUCTIBLE,
                            ROW_SET.PLAN_START_DATE,
                            ROW_SET.PLAN_END_DATE,
                            FIXED_FUNDING_AMOUNT,
                            ANNUAL_ELECTION,
                            FIXED_FUNDING_FLAG,
                            DEDUCTIBLE_RULE_ID,
                            COVERAGE_TIER_NAME,
                            MAX_ROLLOVER_AMOUNT,
                            SYSDATE,
                            P_USER_ID,
                            NULL,
                            NULL
                       FROM BEN_PLAN_COVERAGES
                      WHERE BEN_PLAN_ID = P_BEN_PLAN_ID;
              END IF;*/

               --As per the Ticket #2273 if Coverage is not there for the Previous year
               --we need to create the manual coverage for 'LPF','FSA'
               --Followed the SAMDEV. process as such in Apex, Added by Karthe on 07/10/2015
                    l_ben_plan_end_date := row_set.plan_end_date;
                    if
                        row_set.plan_type in ( 'LPF', 'FSA' )
                        and nvl(row_set.grace_period, 0) = 0
                        and l_ben_plan_end_date > trunc(sysdate)
                    then
                        select
                            count(*)
                        into l_cnt2
                        from
                            ben_plan_coverages
                        where
                            ben_plan_id = l_ben_plan_id_new;

                        if nvl(l_cnt2, 0) = 0 then
                            pc_benefit_plans.create_fsa_coverage(p_new_ben_pln_id, 'SINGLE', p_user_id);
                        end if;

                    end if;

                end if;

            else  -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'v_account_type'
                                                              || v_account_type
                                                              || ' v_resubmit_flag :='
                                                              || v_resubmit_flag);
                if
                    v_account_type = 'ERISA_WRAP'
                    and v_resubmit_flag = 'Y'
                then
                    pc_benefit_plans.update_ben_plan_enrollment_setup(
                        p_ben_plan_id                 => p_new_ben_pln_id,
                        p_plan_start_date             => to_date(lpad(p_new_plan_yr, 10),
        'mm/dd/rrrr'),
                        p_plan_end_date               => to_date(lpad(p_new_end_plan_yr, 10),
        'mm/dd/rrrr'),
                        p_runout_period_days          => p_runout_prd,
                        p_runout_period_term          => p_runout_trm,
                        p_funding_options             => p_funding_options,
                        p_rollover                    => p_rollover,
                        p_new_hire_contrib            =>
                                            case
                                                when p_new_hire = 'Y' then
                                                    'PRORATE'
                                                else
                                                    'N'
                                            end,
                        p_last_update_date            => sysdate,
                        p_last_updated_by             => p_user_id,
                        p_effective_date              => to_date(lpad(p_new_plan_yr, 10),
        'mm/dd/rrrr'),
                        p_minimum_election            => p_min_election,
                        p_maximum_election            => p_max_election,
                        p_grace_period                =>
                                        case
                                            when p_grace = 'Y' then
                                                p_grace_days
                                            else
                                                0
                                        end,
                        p_batch_number                => p_batch_number,
                        p_non_discrm_flag             => p_non_discm,
                        p_plan_docs_flag              => p_plan_docs,
                        p_renewal_flag                => 'Y',
                        p_renewal_date                => sysdate,
                        p_open_enrollment_start_date  => to_date(p_enrlmnt_start, 'dd-mon-rrrr'),
                        p_open_enrollment_end_date    => to_date(p_enrlmnt_endt, 'dd-mon-rrrr'),
                        p_eob_required                => p_eob_required,
                        p_deduct_tax                  => nvl(p_post_tax, 'N'),
                        p_update_limit_match_irs_flag => p_update_limit_match_irs_flag,
                        p_pay_acct_fees               => upper(p_pay_acct_fees),
                        p_source                      => p_source,
                        p_account_type                => 'ERISA_WRAP',
                        p_fiscal_end_date             => null,
                        p_plan_name                   => null,
                        p_plan_number                 => null,
                        p_takeover                    => null,
                        p_org_eff_date                => null,
                        p_plan_type                   => null,
                        p_short_plan_yr               => null,
                        p_plan_doc_ndt_flag           => null,
                        x_return_status               => x_return_status,
                        x_error_message               => x_error_message
                    );

                    l_end_date := to_date ( lpad(p_new_end_plan_yr, 10), 'mm/dd/rrrr' );
                    l_ben_plan_id_new := p_new_ben_pln_id;
                    pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'L_BEN_PLAN_ID_NEW' || l_ben_plan_id_new);
                    for i in (
                        select
                            acc_id,
                            ben_plan_id,
                            plan_type
                        from
                            ben_plan_renewals
                        where
                                renewed_plan_id = l_ben_plan_id_new
                            and to_char(creation_date, 'RRRR') = to_char(sysdate, 'RRRR')
                            and nvl(source, 'ONLINE') = 'ONLINE'
                    ) loop
                        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'Before Email' || l_ben_plan_id_new);
                        l_ben_plan_new := nvl(
                            pc_lookups.get_meaning('FSA_PLAN_TYPE', i.plan_type),
                            i.plan_type
                        );

                        l_acc_id := i.acc_id;
                        l_acc_num := pc_account.get_acc_num_from_acc_id(l_acc_id);
                        l_entrp_id := pc_entrp.get_entrp_id(l_acc_num);
                        l_ben_plan_id_not := p_ben_plan_id;
                        pc_notifications.notify_er_ren_decl_plan(
                            p_acc_id       => l_acc_id,
                            p_ename        => pc_entrp.get_entrp_name(l_entrp_id),
                            p_email        => pc_users.get_email_from_user_id(p_user_id),
                            p_user_id      => p_user_id,
                            p_entrp_id     => l_entrp_id,
                            p_ben_plan_id  => l_ben_plan_id_new,--P_BEN_PLN_NAME => L_PLAN_TYPE,
                            p_ben_pln_name =>
                                            case
                                                when pc_account.get_account_type(l_acc_id) = 'ERISA_WRAP' then
                                                    pc_lookups.get_meaning(l_plan_type, 'PLAN_TYPE_WRAP')
                                                else
                                                    l_plan_type
                                            end,
                            p_ren_dec_flg  => 'R',
                            p_acc_num      => l_acc_num
                        );

                        pc_notifications.notify_er_hra_fsa_plan_renew(
                            p_acc_id       => l_acc_id,
                            p_plan_type    => l_ben_plan_new,
                            p_acc_num      => l_acc_num,
                            p_ben_plan_id  => l_ben_plan_id_new,
                            p_product_type => row_set.product_type,--'FSA',
                            p_user_id      => p_user_id,
                            p_entrp_id     => l_entrp_id
                        );

                    end loop;

                end if;

            end if;

        end if;

/*
      IF L_NOTIFY_FLG = 'Y' THEN
         L_EMAIL_FLG     := 'Y';
         L_ACC_NUM       := PC_ACCOUNT.GET_ACC_NUM_FROM_ACC_ID(ROW_SET.ACC_ID);
         L_ENTRP_ID      := PC_ENTRP.GET_ENTRP_ID(L_ACC_NUM);

         IF ROW_SET.PRODUCT_TYPE = 'HRA' THEN
            SELECT COUNT(*)
              INTO L_COUNT_HRA
              FROM BEN_PLAN_COVERAGES
             WHERE BEN_PLAN_ID   =  P_BEN_PLAN_ID;
         END IF;

         IF L_COUNT_HRA > 0 AND ROW_SET.PRODUCT_TYPE = 'HRA' THEN
            SELECT COUNT(*)
              INTO L_COUNT_HRA_NEW
              FROM BEN_PLAN_COVERAGES
             WHERE BEN_PLAN_ID   =  L_BEN_PlAN_ID_NOT;
         END IF;

         IF NVL(L_COUNT_HRA,0) != NVL(L_COUNT_HRA_NEW,0) THEN
            L_EMAIL_FLG := 'N';
         END IF;

      IF L_EMAIL_FLG = 'Y' THEN
             PC_NOTIFICATIONS.NOTIFY_ER_REN_DECL_PLAN(
                                        P_ACC_ID       => ROW_SET.ACC_ID,
                                        P_ENAME        => PC_ENTRP.GET_ENTRP_NAME(L_ENTRP_ID),
                                        P_EMAIL        => NULL,
                                        P_USER_ID      => P_USER_ID,
                                        P_ENTRP_ID     => L_ENTRP_ID,
                                        P_BEN_PLAN_ID  => L_BEN_PlAN_ID_NOT,
                                        P_BEN_PLN_NAME => L_PLAN_TYPE,
                                        P_REN_DEC_FLG  => 'R',
                                        P_ACC_NUM      => L_ACC_NUM);

             PC_NOTIFICATIONS.NOTIFY_ER_HRA_FSA_PLAN_RENEW(
                                             P_ACC_ID       => ROW_SET.ACC_ID,
                                             P_PLAN_TYPE    => L_BEN_PLAN_NEW,
                                             P_ACC_NUM      => L_ACC_NUM,
                                             P_BEN_PLAN_ID  => L_BEN_PlAN_ID_NOT,
                                             P_PRODUCT_TYPE => ROW_SET.PRODUCT_TYPE,
                                             P_USER_ID      => P_USER_ID,
                                             P_ENTRP_ID     => L_ENTRP_ID);
         END IF;*/
        pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'P_NEW_BEN_PLN_ID' || p_new_ben_pln_id);
        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'E';
            pc_log.log_error('INSRT_ER_BEN_PLAN_ENRLMNT', 'SQLERRM' || sqlerrm);
    end insrt_er_ben_plan_enrlmnt;

    procedure insrt_er_ben_plan_cvrg (
        p_coverage_id     in varchar2,
        p_new_ben_plan_id in varchar2,
        p_coverage_type   in varchar2,
        p_annual_election in varchar2,
        p_deductible      in varchar2,
        p_max_rolovr_amt  in varchar2,
        p_user_id         in varchar2,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is

        l_plan_start_date date;
        l_plan_end_date   date;
        l_old_ben_plan_id number;
        l_email_flg       varchar2(10) := 'Y';
        l_count_hra       number;
        l_count_hra_new   number;
    begin
      /*SELECT PLAN_START_DATE, PLAN_END_DATE
        INTO L_PLAN_START_DATE, L_PLAN_END_DATE
        FROM BEN_PLAN_ENROLLMENT_SETUP
       WHERE BEN_PLAN_ID = P_NEW_BEN_PLAN_ID;*/

        for j in (
            select
                plan_start_date,
                plan_end_date
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id = p_new_ben_plan_id
        ) loop
            l_plan_start_date := j.plan_start_date;
            l_plan_end_date := j.plan_end_date;
        end loop;

        for i in (
            select
                ben_plan_id
            from
                ben_plan_coverages
            where
                coverage_id = p_coverage_id
        ) loop
            l_old_ben_plan_id := i.ben_plan_id;
        end loop;

        insert into ben_plan_coverages (
            coverage_id,
            ben_plan_id,
            acc_id,
            coverage_type,
            deductible,
            start_date,
            end_date,
            fixed_funding_amount,
            annual_election,
            fixed_funding_flag,
            deductible_rule_id,
            coverage_tier_name,
            max_rollover_amount,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                coverage_seq.nextval,
                p_new_ben_plan_id,
                acc_id,
                p_coverage_type,
                p_deductible,
                l_plan_start_date,
                l_plan_end_date,
                fixed_funding_amount,
                p_annual_election,
                fixed_funding_flag,
                deductible_rule_id,
                coverage_tier_name,
                p_max_rolovr_amt,
                sysdate,
                p_user_id,
                null,
                null
            from
                ben_plan_coverages
            where
                coverage_id = p_coverage_id;

        select
            count(*)
        into l_count_hra
        from
            ben_plan_coverages
        where
            ben_plan_id = l_old_ben_plan_id;

        if l_count_hra > 0 then
            select
                count(*)
            into l_count_hra_new
            from
                ben_plan_coverages
            where
                ben_plan_id = p_new_ben_plan_id;

        end if;

        if nvl(l_count_hra, 0) != nvl(l_count_hra_new, 0) then
            l_email_flg := 'N';
        end if;

        if l_email_flg = 'Y' then
            for i in (
                select
                    acc_id,
                    pc_account.get_acc_num_from_acc_id(acc_id)                        acc_num,
                    pc_entrp.get_entrp_id(pc_account.get_acc_num_from_acc_id(acc_id)) entrp_id,
                    nvl(
                        pc_lookups.get_meaning('HRA_PLAN_TYPE', plan_type),
                        plan_type
                    )                                                                 plan_type
                from
                    ben_plan_enrollment_setup
                where
                    ben_plan_id = p_new_ben_plan_id
            ) loop
                pc_notifications.notify_er_ren_decl_plan(
                    p_acc_id       => i.acc_id,
                    p_ename        => pc_entrp.get_entrp_name(i.entrp_id),
                    p_email        => null,
                    p_user_id      => p_user_id,
                    p_entrp_id     => i.entrp_id,
                    p_ben_plan_id  => p_new_ben_plan_id,
                    p_ben_pln_name => i.plan_type,
                    p_ren_dec_flg  => 'R',
                    p_acc_num      => i.acc_num
                );

                pc_notifications.notify_er_hra_fsa_plan_renew(
                    p_acc_id       => i.acc_id,
                    p_plan_type    => i.plan_type,
                    p_acc_num      => i.acc_num,
                    p_ben_plan_id  => p_new_ben_plan_id,
                    p_product_type => 'HRA',
                    p_user_id      => p_user_id,
                    p_entrp_id     => i.entrp_id
                );

            end loop;
        end if;

        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'E';
    end;

    procedure insert_irs_amend_det (
        p_acc_id        in number,
        p_plan_type     in varchar2,
        p_acc_deny_flag in varchar2,
        p_userid        in varchar2,
        p_irs_id        in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';
      --ACCEPT_FLAG 'Y' IRS Accepted
      --ACCEPT_FLAG 'N' IRS Denied
        insert into irs_acc_amendments (
            acc_id,
            plan_type,
            accept_flag,
            irs_id,
            creation_date,
            created_by
        ) values ( p_acc_id,
                   p_plan_type,
                   p_acc_deny_flag,
                   p_irs_id,
                   sysdate,
                   p_userid );

    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_return_status := 'E';
    end insert_irs_amend_det;

    procedure insert_ben_plan_decline_det (
        p_er_ben_plan_id in number,
        p_acc_id         in number,
        p_lookup_code    in varchar2,
        p_deny_reason    in varchar2,
        p_deny_flag      in varchar2,
        p_userid         in varchar2,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    ) is

        v_plan_type      varchar2(10);
        l_notify_flg     varchar2(1) := 'N';
        l_ben_plan_new   varchar2(300);
        l_effective_plan date := '31-DEC-' || to_char(sysdate, 'RRRR');
        l_acc_num        varchar2(100);
        l_entrp_id       varchar2(100);
        l_account_type   varchar2(100) := pc_account.get_account_type(p_acc_id);
        l_email          varchar2(100);
    begin
        pc_log.log_error('error', ' P_ER_BEN_PLAN_ID ==>' || p_er_ben_plan_id);
        if l_account_type <> 'COBRA' then
            select
                count(*)
            into cnt
            from
                ben_plan_denials
            where
                    acc_id = p_acc_id
                and ben_plan_id = p_er_ben_plan_id; -- AND ACCEPT_FLAG=P_DENY_FLAG;
        else
            select
                count(*)
            into cnt
            from
                ben_plan_denials bp
            where
                    acc_id = p_acc_id
                and start_date >= (
                    select
                        greatest(
                            max(a.start_date),
                            trunc(sysdate, 'YYYY')
                        )
                    from
                        ar_invoice       a,
                        account          b,
                        ar_invoice_lines c
                    where
                            a.acc_id = b.acc_id
                        and b.account_type = 'COBRA'
                        and a.invoice_id = c.invoice_id
                        and b.acc_id = bp.acc_id
                        and c.rate_code in ( '1', '30' )
                );

        end if;

        for i in (
            select
                acc_num,
                entrp_id
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_acc_num := i.acc_num;
            l_entrp_id := i.entrp_id;
        end loop;

        select
            entrp_email
        into l_email
        from
            enterprise
        where
            entrp_id = l_entrp_id;

        if cnt = 0 then
            insert into ben_plan_denials (
                ben_plan_id,
                acc_id,
                lookup_code,
                accept_flag,
                deny_reason,
                creation_date,
                created_by
            ) values ( p_er_ben_plan_id,
                       p_acc_id,
                       p_lookup_code,
                       p_deny_flag,
                       p_deny_reason,
                       sysdate,
                       p_userid );

        end if;
            /*SELECT PLAN_TYPE
              INTO V_PLAN_TYPE
              FROM BEN_PLAN_ENROLLMENT_SETUP
             WHERE BEN_PLAN_ID=P_ER_BEN_PLAN_ID;*/

        for j in (
            select
                plan_type
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id = p_er_ben_plan_id
        ) loop
            v_plan_type := j.plan_type;
        end loop;

        if v_plan_type in ( 'TRN', 'PKG', 'UA1' ) then --AND P_DENY_FLAG='N'THEN
            update ben_plan_enrollment_setup
            set
                plan_end_date = to_date(to_char(plan_end_date, 'DDMM')
                                        || to_char(sysdate, 'RR'),
        'DDMMRR')
            where
                ben_plan_id = p_er_ben_plan_id;

        end if;

        l_notify_flg := 'Y';
        l_ben_plan_new := pc_lookups.get_meaning('FSA_PLAN_TYPE', v_plan_type);
        if l_account_type in ( 'ERISA_WRAP', 'FORM_5500' ) then
            l_ben_plan_new := pc_lookups.get_meaning(v_plan_type,
                                                     'PLAN_TYPE_' || substr(l_account_type, -4));
        end if;

        if l_notify_flg = 'Y' then
            pc_notifications.notify_er_ren_decl_plan(
                p_acc_id       => p_acc_id,
                p_ename        => pc_entrp.get_entrp_name(l_entrp_id),
                p_email        => l_email,
                p_user_id      => p_userid,
                p_entrp_id     => l_entrp_id,
                p_ben_plan_id  => p_er_ben_plan_id,
                p_ben_pln_name => l_ben_plan_new,
                p_ren_dec_flg  => 'D',
                p_acc_num      => l_acc_num
            );
        end if;

        x_return_status := 'S';
    exception
        when others then
            pc_log.log_error('error', 'comming to error place');
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_return_status := 'E';
    end insert_ben_plan_decline_det;

    function is_plan_renewed_already (
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return tbl_rnwd
        pipelined
    is

        l_ben_status    varchar2(1);
        l_creation_dt   varchar2(100);
        l_condition     boolean := true;
        l_plan_end_date date;
        rec             rec_rnwd;
    begin
        for i in (
            select
                'Y'                                          next_yr_status,
                to_char(ee_plan.creation_date, 'mm/dd/rrrr') creation_date
            from
                ben_plan_enrollment_setup ee_plan,
                ben_plan_renewals         a
            where
                    ee_plan.acc_id = p_acc_id
                and ee_plan.status = 'A'
                and ee_plan.plan_type = a.plan_type /*Ticket#7458.Plans ending in Jan 2019 were not showing up for renewal */
                and ee_plan.acc_id = a.acc_id
                and to_char(ee_plan.plan_start_date, 'YYYY') >= to_char(sysdate, 'YYYY') +
                                                                case
                                                                    when to_char(ee_plan.plan_end_date, 'YYYY') > to_char(sysdate, 'YYYY'
                                                                    ) then
                                                                        0
                                                                    else
                                                                        1
                                                                end
                and ee_plan.plan_type = p_plan_type
                and ee_plan.plan_type not in ( 'TRN', 'PKG', 'UA1' )
                and not exists (
                    select
                        1
                    from
                        ben_plan_denials
                    where
                        ben_plan_id = ee_plan.ben_plan_id
                )
        ) loop
            l_ben_status := i.next_yr_status;
            l_creation_dt := i.creation_date;
        end loop;

        dbms_output.put_line('L_CREATION_DT==>' || l_creation_dt);
      --Added below because plan is getting renewed after the Expiry date 60 Days,
      --in which the above query is failing to retrun values as the start date is lesser
      --than the SYSDATE
        if l_creation_dt is null then
         /* 8545: Commented by Joshi
         FOR K IN (SELECT TRUNC(PLAN_END_DATE) PLAN_END_DATE
                     FROM BEN_PLAN_ENROLLMENT_SETUP
                    WHERE BEN_PLAN_ID = (SELECT MAX(BEN_PLAN_ID)
                                           FROM BEN_PLAN_ENROLLMENT_SETUP
                                          WHERE ACC_ID = P_ACC_ID
                                            AND PLAN_TYPE = P_ACC_ID)) LOOP
             L_PLAN_END_DATE := K.PLAN_END_DATE;
         END LOOP;
         */

         /* Added by Joshi for 8545: get latest plan end date for the account */
            for k in (
                select
                    trunc(max(plan_end_date)) plan_end_date
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = p_acc_id
                    and plan_type = p_plan_type
            ) loop
                l_plan_end_date := k.plan_end_date;
            end loop;
          /* code ends here 8545: get latest plan end date for the account */

            dbms_output.put_line('L_PLAN_END_DATE==>' || l_plan_end_date);

         -- 7951: Joshi logic changed as per Renewal logic.
         --IF ((TRUNC(L_PLAN_END_DATE) BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + 90)
         --    OR (TRUNC(SYSDATE) BETWEEN TRUNC(L_PLAN_END_DATE) AND TRUNC(L_PLAN_END_DATE) + 180))
            if
                ( trunc(l_plan_end_date) between trunc(sysdate - pc_web_er_renewal.g_after_days) and trunc(sysdate + pc_web_er_renewal.g_prior_days
                ) )
                and p_plan_type not in ( 'TRN', 'PKG', 'UA1' )
            then
                l_condition := false;
                dbms_output.put_line('L_CONDITION==>' || 'FALSE');
            end if;

            l_ben_status := null;
            l_creation_dt := null;
            if l_condition then
                for i in (
                    select
                        'Y'                                  next_yr_status,
                        to_char(creation_date, 'mm/dd/rrrr') creation_date
                    from
                        ben_plan_enrollment_setup ee_plan
                    where
                            ee_plan.acc_id = p_acc_id
                        and ee_plan.status = 'A'
                        and to_char(ee_plan.plan_end_date, 'YYYY') >= to_char(sysdate, 'YYYY')
                        and ee_plan.plan_type = p_plan_type
                        and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                        and not exists (
                            select
                                1
                            from
                                ben_plan_denials
                            where
                                ben_plan_id = ee_plan.ben_plan_id
                        )
                ) loop
                    l_ben_status := i.next_yr_status;
                    l_creation_dt := i.creation_date;
                end loop;
            end if;

        end if;

      --Commented by Karthe as the for loop below record population is brought outside the loop
      /*IF L_CREATION_DT IS NOT NULL THEN
        L_TBL.EXTEND;
        L_TBL(L_TBL.COUNT).DATED     := L_CREATION_DT;
        L_TBL(L_TBL.COUNT).FLAG      := NVL (L_BEN_STATUS, 'N');
        L_TBL(L_TBL.COUNT).PLAN_TYPE := P_PLAN_TYPE;
      END IF;*/

        dbms_output.put_line('3 L_CREATION_DT==>' || l_creation_dt);
        for i in (
            select
                'Y'                                    next_yr_status,
                to_char(a.creation_date, 'mm/dd/rrrr') creation_date
            from
                ben_plan_renewals         a,
                ben_plan_enrollment_setup b
            where
                    a.acc_id = p_acc_id
                and a.acc_id = b.acc_id
                and a.plan_type = p_plan_type
                and b.status = 'A'
               -- AND TO_CHAR(A.CREATION_DATE,'RRRR') = TO_CHAR(SYSDATE,'RRRR')
                /* Renewals Should not be dependent on creation date . Ticket#4858 */
                and to_char(a.start_date, 'YYYY') >= to_char(sysdate, 'YYYY') +
                                                     case
                                                         when to_char(a.end_date, 'rrrr') > to_char(sysdate, 'rrrr') then
                                                             0
                                                         else
                                                             1
                                                     end
                and not exists (
                    select
                        1
                    from
                        ben_plan_denials c
                    where
                        c.ben_plan_id = b.ben_plan_id
                )
        ) loop
            l_ben_status := i.next_yr_status;
            l_creation_dt := i.creation_date;
         --Commented by Karthe as we moved the code down
         /*IF L_CREATION_DT IS NOT NULL THEN
            L_TBL.EXTEND;
            L_TBL(L_TBL.COUNT).DATED     := L_CREATION_DT;
            L_TBL(L_TBL.COUNT).FLAG      := NVL (L_BEN_STATUS, 'N');
            L_TBL(L_TBL.COUNT).PLAN_TYPE := P_PLAN_TYPE;
         END IF;*/
        end loop;

        pc_log.log_error('Here..end second loop', l_creation_dt);
        dbms_output.put_line('3 L_CREATION_DT final==>' || l_creation_dt);
        rec.dated := l_creation_dt;
        rec.flag := nvl(l_ben_status, 'N');
        rec.plan_type := p_plan_type;

      --Commented by Karthe as we can still retun it as rec type
      /*FOR I IN 1 .. L_TBL.COUNT LOOP
         PIPE ROW(L_TBL(I));
      END LOOP;*/
        pipe row ( rec );
    exception
        when others then
            dbms_output.put_line(sqlerrm
                                 || ' '
                                 || sqlcode);
            null;
    end is_plan_renewed_already;

    function is_plan_renew_trn_pkg (
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return tbl_rnwd
        pipelined
    is

        l_ben_status    varchar2(1);
        l_creation_dt   varchar2(100);
        rec             rec_rnwd;
        l_plan_end_date date;
        l_condition     boolean := true;
    begin

      /*
      FOR I
         IN (SELECT 'Y' NEXT_YR_STATUS,
                    TO_CHAR(A.CREATION_DATE,'mm/dd/rrrr')CREATION_DATE
               FROM BEN_PLAN_RENEWALS A, BEN_PLAN_ENROLLMENT_SETUP B
              WHERE A.ACC_ID = P_ACC_ID
                AND A.ACC_ID = B.ACC_ID
                AND A.PLAN_TYPE = P_PLAN_TYPE
                AND B.STATUS = 'A'
                AND TO_CHAR(A.CREATION_DATE,'RRRR') = TO_CHAR(SYSDATE,'RRRR')
                AND NOT EXISTS (SELECT 1
                                  FROM BEN_PLAN_DENIALS C
                                 WHERE C.BEN_PLAN_ID = B.BEN_PLAN_ID))
      LOOP
         L_BEN_STATUS     := I.NEXT_YR_STATUS;
         L_CREATION_DT    := I.CREATION_DATE;
      END LOOP;

        FOR K IN ( SELECT MAX(A.END_DATE) END_DATE , MAX(A.CREATION_DATE ) CREATION_DATE
                   FROM BEN_PLAN_RENEWALS A, BEN_PLAN_ENROLLMENT_SETUP B
				  WHERE A.ACC_ID = P_ACC_ID
                    AND A.ACC_ID = B.ACC_ID
                    AND A.PLAN_TYPE = P_PLAN_TYPE
                    AND B.STATUS = 'A'
					AND NOT EXISTS (SELECT 1
                                  FROM BEN_PLAN_DENIALS C
                                 WHERE C.BEN_PLAN_ID = A.BEN_PLAN_ID))
           LOOP
                IF  K.END_DATE IS NOT NULL  THEN
                     --l_current_date :=  K.END_DATE ; --ADD_MONTHS(k.END_DATE,12) ;
                    IF  (  TRUNC(K.END_DATE)    BETWEEN  TRUNC(SYSDATE) AND TRUNC(SYSDATE)+ G_AFTER_DAYS
                        OR TRUNC(SYSDATE) BETWEEN TRUNC(K.END_DATE) AND TRUNC(K.END_DATE) + G_PRIOR_DAYS
                        ) THEN
                        L_BEN_STATUS     := 'Y';
                        L_CREATION_DT    := k.CREATION_DATE;

                    ELSE
                        L_BEN_STATUS     := 'N';

                    END IF;
                END IF;
            END LOOP;

      REC.DATED :=   L_CREATION_DT;
      REC.FLAG  :=   NVL (L_BEN_STATUS, 'N');
      */

        for i in (
            select
                'Y'                                          next_yr_status,
                to_char(ee_plan.creation_date, 'mm/dd/rrrr') creation_date
            from
                account           a,
                ben_plan_renewals ee_plan
            where
                    a.acc_id = ee_plan.acc_id
                and ee_plan.acc_id = p_acc_id
                and ee_plan.start_date > sysdate    -- Commented by Swamy for Ticket#12120 15/04/2024
                    --AND EE_PLAN.START_DATE  > pc_web_er_renewal.Get_plan_end_date_for_trn_pkg( P_ACC_ID, P_PLAN_TYPE)  -- Added by Swamy for Ticket#12120 15/04/2024
                and ee_plan.end_date > sysdate
                and plan_type in ( 'TRN', 'PKG', 'UA1' )
                and not exists (
                    select
                        1
                    from
                        ben_plan_denials
                    where
                        ben_plan_id = ee_plan.ben_plan_id
                )
        ) loop
            l_ben_status := i.next_yr_status;
            rec.dated := i.creation_date;
        end loop;

        rec.flag := nvl(l_ben_status, 'N');
        pipe row ( rec );
    exception
        when others then
            null;
    end is_plan_renew_trn_pkg;

    function get_renewed_ben_plan_id (
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return varchar2 is
        l_ben_plan_id varchar2(20);
        l_flag        varchar2(1);
    begin
       /*SELECT FLAG
         INTO L_FLAG
         FROM TABLE(PC_WEB_ER_RENEWAL.IS_PLAN_RENEWED_ALREADY(P_ACC_ID,P_PLAN_TYPE));*/

        for i in (
            select
                flag
            from
                table ( pc_web_er_renewal.is_plan_renewed_already(p_acc_id, p_plan_type) )
        ) loop
            l_flag := i.flag;
        end loop;

        if l_flag = 'Y' then
          /*SELECT BEN_PLAN_ID
            INTO L_BEN_PLAN_ID
            FROM BEN_PLAN_ENROLLMENT_SETUP A
           WHERE ACC_ID = P_ACC_ID
             AND PLAN_TYPE = P_PLAN_TYPE
             AND STATUS = 'A'
             AND TO_CHAR (PLAN_START_DATE, 'YYYY') >=  TO_CHAR (SYSDATE, 'YYYY')-- + 1
             + CASE WHEN TO_CHAR(PLAN_END_DATE,'RRRR')>TO_CHAR(SYSDATE,'RRRR')THEN 0 ELSE 1 END
             AND NOT EXISTS (SELECT 1
                               FROM BEN_PLAN_DENIALS
                              WHERE BEN_PLAN_ID = A.BEN_PLAN_ID);*/

            for i in (
                select
                    ben_plan_id
                from
                    ben_plan_enrollment_setup a
                where
                        acc_id = p_acc_id
                    and plan_type = p_plan_type
                    and status = 'A'
                    and to_char(plan_start_date, 'YYYY') >= to_char(sysdate, 'YYYY')-- + 1
                     +
                                                            case
                                                                when to_char(plan_end_date, 'RRRR') > to_char(sysdate, 'RRRR') then
                                                                    0
                                                                else
                                                                    1
                                                            end
                    and not exists (
                        select
                            1
                        from
                            ben_plan_denials
                        where
                            ben_plan_id = a.ben_plan_id
                    )
            ) loop
                l_ben_plan_id := i.ben_plan_id;
            end loop;

            return l_ben_plan_id;
        else
            return null;
        end if;

    end;

    function is_plan_declined (
        p_er_ben_plan_id in number,
        p_acc_id         in number
    ) return tbl_dclnd
        pipelined
    is
        rec             rec_dclnd;
        l_flg           varchar2(10);
        l_creation_date varchar2(100);
    begin
        for i in (
            select
                'Y'                                    flg,
                to_char(a.creation_date, 'mm/dd/rrrr') creation_date,
                c.plan_type
            from
                ben_plan_denials          a,
                ben_plan_enrollment_setup c
            where
                    a.ben_plan_id = p_er_ben_plan_id
                and a.acc_id = p_acc_id
                and a.ben_plan_id = c.ben_plan_id
            union
            select
                'Y'                                    flg,
                to_char(a.creation_date, 'mm/dd/rrrr') creation_date,
                c.account_type
            from
                ben_plan_denials a,
                account          c
            where
                    c.account_type = 'COBRA'
                and a.acc_id = p_acc_id
                and a.acc_id = c.acc_id
        )
                 -- AND ACCEPT_FLAG = 'N')
         loop
            rec.dated := i.creation_date;
            rec.flag := nvl(i.flg, 'N');
            rec.plan_type := i.plan_type;
            pipe row ( rec );
        end loop;
    end;

    function is_irs_amended (
        p_acc_id in number,
        p_irs_id in number
    )--,P_PLAN_TYPE VARCHAR2)
     return irs_tbl
        pipelined
    is
        rec irs_det;
    begin
        for i in (
            select
                irs_id,
                pc_lookups.get_meaning(accept_flag, 'IRS_ACC_REJ_CODE') accept_decline
            from
                irs_acc_amendments
            where
                    acc_id = p_acc_id
                and irs_id = p_irs_id
        )
                   --AND PLAN_TYPE = P_PLAN_TYPE)
         loop
            rec.irs_id := i.irs_id;
            rec.accept_decline := i.accept_decline;
            pipe row ( rec );
        end loop;
    end;

   --This Function is used to Display the Banner Accordingly before 90 days of any Plan Renewal
    function emp_plan_renewal_disp (
        p_acc_id in number
    ) return varchar2 is
        l_count number := 0;
    begin
/*    SELECT SUM(REN_COUNT)
    INTO   L_COUNT
    FROM ( -- non transit FSA plans
       SELECT COUNT(*) REN_COUNT
          FROM ACCOUNT A,
             BEN_PLAN_ENROLLMENT_SETUP B
       WHERE A.ACC_ID = P_ACC_ID
         AND A.ACC_ID                      = B.ACC_ID
         AND A.ENTRP_ID                    = B.ENTRP_ID
         AND PRODUCT_TYPE                 = 'FSA'
         AND PLAN_TYPE NOT IN  ('TRN','PKG','UA1','IIR')
         AND ACCOUNT_STATUS                = 1
         AND STATUS                        = 'A'
         AND 'N'= (SELECT FLAG FROM TABLE(PC_WEB_ER_RENEWAL.IS_PLAN_RENEWED_ALREADY(A.ACC_ID,PLAN_TYPE)))
         AND ( TRUNC(PLAN_END_DATE) BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE + 90)
         OR  TRUNC(PLAN_END_DATE) BETWEEN TRUNC(SYSDATE-60) AND TRUNC(SYSDATE))
         AND NOT EXISTS (SELECT 1
                           FROM BEN_PLAN_ENROLLMENT_SETUP C
                          WHERE C.ACC_ID    = B.ACC_ID
                            AND C.PLAN_TYPE = B.PLAN_TYPE
                            AND C.PLAN_END_DATE > B.PLAN_END_DATE)
         AND NOT EXISTS (SELECT 1
                           FROM BEN_PLAN_DENIALS
                          WHERE BEN_PLAN_ID = B.BEN_PLAN_ID)
         UNION -- Transit plans
       SELECT  COUNT(*) REN_COUNT
          FROM ACCOUNT A,
             BEN_PLAN_ENROLLMENT_SETUP B
       WHERE A.ACC_ID = P_ACC_ID
         AND A.ACC_ID                      = B.ACC_ID
         AND A.ENTRP_ID                    = B.ENTRP_ID
         AND PRODUCT_TYPE                 = 'FSA'
        --Ticket#4851.Plan renewed in Sep should not show renewal link in October
         AND  MONTHS_BETWEEN(SYSDATE,B.PLAN_START_DATE) >= 9
         AND PLAN_TYPE   IN  ('TRN','PKG','UA1')
         AND ACCOUNT_STATUS                = 1
         AND STATUS                        = 'A'
          AND 'N'=  (SELECT FLAG FROM TABLE(PC_WEB_ER_RENEWAL.IS_PLAN_RENEW_TRN_PKG  (A.ACC_ID,PLAN_TYPE)))
         AND ADD_MONTHS(TRUNC(SYSDATE,'YYYY'),12)
                BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE+ 90)
         AND NOT EXISTS (SELECT 1
                           FROM BEN_PLAN_RENEWALS E
                          WHERE E.BEN_PLAN_ID = B.BEN_PLAN_ID
                            AND TO_CHAR(CREATION_DATE,'RRRR') = TO_CHAR(SYSDATE,'RRRR'))
         AND NOT EXISTS (SELECT 1
                           FROM BEN_PLAN_DENIALS
                          WHERE BEN_PLAN_ID = B.BEN_PLAN_ID)
        UNION -- HRA Plans
        SELECT  COUNT(*) REN_COUNT
          FROM ACCOUNT A,
             BEN_PLAN_ENROLLMENT_SETUP B
       WHERE   A.ACC_ID = P_ACC_ID
         AND  A.ACC_ID                      = B.ACC_ID
         AND A.ENTRP_ID                    = B.ENTRP_ID
         AND NVL(SF_ORDINANCE_FLAG, 'N')  != 'Y'
         AND PRODUCT_TYPE                 = 'HRA'
          AND ACCOUNT_STATUS                = 1
         AND STATUS                        = 'A'
                       AND 'N'= (SELECT FLAG FROM TABLE(PC_WEB_ER_RENEWAL.IS_PLAN_RENEWED_ALREADY(A.ACC_ID,PLAN_TYPE)))
         AND ( TRUNC(PLAN_END_DATE) BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE + 90)
         OR  TRUNC(PLAN_END_DATE) BETWEEN TRUNC(SYSDATE-60) AND TRUNC(SYSDATE))
         /*Ticket#5516.Modified on 13/04/18 */
         --AND NOT EXISTS (SELECT 1
           --                FROM DEDUCTIBLE_RULE
             --             WHERE RULE_TYPE LIKE 'EMBED%'
               --             AND ENTRP_ID = A.ENTRP_ID
                 --           AND PC_ACCOUNT.IS_STACKED_ACCOUNT (ENTRP_ID) = 'Y'
                  --          AND PRODUCT_TYPE = 'HRA')
 /*        AND NOT EXISTS (SELECT 1
                           FROM BEN_PLAN_RENEWALS E
                          WHERE E.BEN_PLAN_ID = B.BEN_PLAN_ID
                            AND TO_CHAR(CREATION_DATE,'RRRR') = TO_CHAR(SYSDATE,'RRRR'))
         AND NOT EXISTS (SELECT 1
                           FROM BEN_PLAN_DENIALS
                          WHERE BEN_PLAN_ID = B.BEN_PLAN_ID));
*/

        select
            count(*)
        into l_count
        from
            table ( pc_web_er_renewal.get_er_plans(p_acc_id) )
        where
                renewed = 'N'
            and declined = 'N';

        if nvl(l_count, 0) = 0 then
            return 'N';
        else
            return 'Y';
        end if;

    exception
        when others then
            return 'N';
    end emp_plan_renewal_disp;

    function is_trn_pkg_ua1_ren_exp (
        p_plan_end_date in date,
        p_ben_plan_id   in number
    ) return varchar2 is
        v_plan_renewed  varchar2(1);
        v_count_90_days number;
    begin
        if to_date(to_char(p_plan_end_date, 'DD-MON-')
                   || to_char(sysdate, 'RRRR'),
        'DD-MON-YYYY') between trunc(sysdate) and trunc(sysdate) + 90 then
            select
                count(*)
            into v_count_90_days
            from
                ben_plan_renewals e
            where
                    ben_plan_id = p_ben_plan_id
                and start_date = to_date('01-JAN'
                                         || to_char(sysdate, 'RRRR') + 1,
        'DD-MON-YYYY')
                and end_date = to_date('31-DEC'
                                       || to_char(sysdate, 'RRRR') + 1,
        'DD-MON-YYYY');

            if nvl(v_count_90_days, 0) <> 0 then
                return 'N';
            else
                return 'Y';
            end if;
       --ELSIF TRUNC(SYSDATE) BETWEEN TO_DATE(TO_CHAR(P_PLAN_END_DATE,'DD-MON-')||TO_CHAR(SYSDATE,'RRRR') - 1,'DD-MON-YYYY') AND TRUNC TO_DATE(TO_CHAR(P_PLAN_END_DATE,'DD-MON-')||TO_CHAR(SYSDATE,'RRRR') - 1,'DD-MON-YYYY')+ 60
       --   NULL;
        end if;
    end is_trn_pkg_ua1_ren_exp;

    procedure pos_renewal_det_fsa (
        p_acc_id in number default null
    ) is

        type rec_ben_plan_setup is
            table of ben_plan_enrollment_setup%rowtype;
        type rec_ben_plan_renewal is
            table of ben_plan_renewals%rowtype;
        type rec_worksheet is record (
            work_book varchar2(4000)
        );
        type tbl_worksheet is
            table of rec_worksheet;
        l_ben_plan_new        rec_ben_plan_setup;
        l_ben_plan_renew_new  rec_ben_plan_renewal;
        l_worksheet           rec_worksheet;
        v_start               varchar2(1) := 'Y';
        v_old_data            varchar2(1);
        v_file_id             number;
        v_funding_options     varchar2(4000);
        v_funding_options_old varchar2(4000);
        v_work_sheet          varchar2(4000);
        v_file_name           varchar2(4000);
        r                     number := 0;
        v_plan_type           varchar2(100);
        v_ben_plan_name       varchar2(100);
        v_plan_type_new       varchar2(100);
        v_plan_start_date     varchar2(100);
        v_plan_end_date       varchar2(100);
        v_open_enr_start_date varchar2(100);
        v_open_enr_end_date   varchar2(100);
        v_effect_date         varchar2(100);
        v_status              varchar2(100);
        v_fiscal_end_date     varchar2(100);
        v_takeover            varchar2(100);
        v_orig_eff_date       varchar2(100);
        v_amend_date          varchar2(100);
        v_plan_docs_flag      varchar2(100);
        v_non_discrm_flag     varchar2(100);
        v_min_election        number;
        v_max_election        number;
        v_payroll_contrib     number;
        v_rollover            varchar2(100);
        v_new_hire_contrib    varchar2(100);
        v_effect_end_date     varchar2(100);
        v_term_req_date       varchar2(100);
        v_term_elig           varchar2(100);
        v_runout_period_days  number;
        v_runout_period_term  varchar2(100);
        v_grace_period        number;
        v_tran_period         varchar2(100);
        v_tran_limit          varchar2(100);
        v_iias_enable         varchar2(100);
        v_claim_reimb_by      varchar2(100);
        v_reimb_start_date    varchar2(100);
        v_reimb_end_date      varchar2(100);
        v_allow_subst         varchar2(100);
        v_note                varchar2(4000);
        v_html_msg            varchar2(4000);
        v_email               varchar2(4000);
        v_count_other_fsa     number;
        v_start_date_old      varchar2(100);
        v_end_date_old        varchar2(100);
        v_entrp_id            number;
        v_acc_id              number;
    begin
        select
            *
        bulk collect
        into l_ben_plan_new
        from
            (
                select
                    *
                from
                    ben_plan_enrollment_setup a
                where
                        trunc(creation_date) > trunc(sysdate) - 1
                    and p_acc_id is null
                    and entrp_id is not null
                    and product_type = 'FSA'
                    and exists (
                        select
                            1
                        from
                            ben_plan_enrollment_setup b
                        where
                                b.ben_plan_id != a.ben_plan_id
                            and b.acc_id = a.acc_id
                            and b.plan_type = a.plan_type
                    )
                union
                select
                    *
                from
                    ben_plan_enrollment_setup a
                where
                        acc_id = p_acc_id
                    and plan_start_date > sysdate
                    and entrp_id is not null
                    and product_type = 'FSA'
                    and exists (
                        select
                            1
                        from
                            ben_plan_enrollment_setup b
                        where
                                b.ben_plan_id != a.ben_plan_id
                            and b.acc_id = a.acc_id
                            and b.plan_type = a.plan_type
                    )
            );

        select
            *
        bulk collect
        into l_ben_plan_renew_new
        from
            (
                select
                    *
                from
                    ben_plan_renewals a
                where
                        trunc(creation_date) > trunc(sysdate) - 1
                    and p_acc_id is null
                    and plan_type in ( 'TRN', 'UA1', 'PKG' )
                    and exists (
                        select
                            1
                        from
                            ben_plan_enrollment_setup b
                        where
                            b.ben_plan_id = a.ben_plan_id
                    )
                union
                select
                    *
                from
                    ben_plan_renewals a
                where
                        acc_id = p_acc_id
                    and plan_type in ( 'TRN', 'UA1', 'PKG' )
                    and acc_id = 417529
                    and exists (
                        select
                            1
                        from
                            ben_plan_enrollment_setup b
                        where
                            b.ben_plan_id = a.ben_plan_id
                    )
            );

        if l_ben_plan_new.count > 0
        or l_ben_plan_renew_new.count > 0 then
            v_file_id := pc_file_upload.insert_file_seq('DAILY_RENEWAL_BEN_PLAN_FSA');
            v_file_name := 'FSA_Renewal_Changes_Report_'
                           || v_file_id
                           || '_'
                           || to_char(sysdate, 'YYYYMMDDHH24MISS')
                           || '.xls';

            dbms_output.put_line('Strat file name' || v_file_name);
            gen_xl_xml.create_excel('MAILER_DIR', v_file_name);
            gen_xl_xml.create_style('BEN_PLAN_HEADER', 'Calibri', 'Black', 10,
                                    p_bold => true);
            gen_xl_xml.create_style('BEN_PLAN_HEADER_BEN_PLAN', 'Calibri', 'Red', 10,
                                    p_bold => true);
            gen_xl_xml.create_style('BEN_PLAN_HEADER_BEN_PLAN1', 'Calibri', 'Blue', 10,
                                    p_bold => true);
            gen_xl_xml.create_style('BEN_PLAN_COLUMN', 'Calibri', 'Black', 9);
            gen_xl_xml.create_style('BEN_PLAN_COLUMN_CHG', 'Calibri', 'Green', 9,
                                    p_backcolor => 'Yellow');
            for ik in 1..l_ben_plan_new.count loop
                l_worksheet.work_book := pc_entrp.get_acc_num(l_ben_plan_new(ik).entrp_id)
                                         || '-'
                                         || l_ben_plan_new(ik).plan_type;

                gen_xl_xml.create_worksheet(l_worksheet.work_book);
              --V_WORK_SHEET := L_WORKSHEET.WORK_BOOK;
            end loop;

            for ik in 1..l_ben_plan_renew_new.count loop
                l_worksheet.work_book := pc_account.get_acc_num_from_acc_id(l_ben_plan_renew_new(ik).acc_id)
                                         || '-'
                                         || l_ben_plan_renew_new(ik).plan_type;

                gen_xl_xml.create_worksheet(l_worksheet.work_book);
              --V_WORK_SHEET := L_WORKSHEET.WORK_BOOK;
            end loop;

        end if;

        for i in 1..l_ben_plan_new.count loop
            v_old_data := 'N';
            v_start := 'N';
            v_funding_options := null;
            r := 1;
            v_work_sheet := pc_entrp.get_acc_num(l_ben_plan_new(i).entrp_id)
                            || '-'
                            || l_ben_plan_new(i).plan_type;

            v_plan_type := null;
            v_ben_plan_name := null;
            v_plan_start_date := null;
            v_plan_end_date := null;
            v_open_enr_start_date := null;
            v_open_enr_end_date := null;
            v_effect_date := null;
            v_status := null;
            v_fiscal_end_date := null;
            v_takeover := null;
            v_orig_eff_date := null;
            v_amend_date := null;
            v_plan_docs_flag := null;
            v_non_discrm_flag := null;
            v_min_election := null;
            v_max_election := null;
            v_payroll_contrib := null;
            v_funding_options_old := null;
            v_rollover := null;
            v_new_hire_contrib := null;
            v_effect_end_date := null;
            v_term_req_date := null;
            v_term_elig := null;
            v_runout_period_days := null;
            v_runout_period_term := null;
            v_grace_period := null;
            v_tran_period := null;
            v_tran_limit := null;
            v_iias_enable := null;
            v_claim_reimb_by := null;
            v_reimb_start_date := null;
            v_reimb_end_date := null;
            v_allow_subst := null;
            v_note := null;
            v_acc_id := null;
            for ak in (
                select
                    (
                        select
                            meaning
                        from
                            fsa_hra_plan_type
                        where
                            lookup_code = plan_type
                    )                                                                  plan_type,
                    ben_plan_name,
                    to_char(plan_start_date, 'MM/DD/YYYY')                             plan_start_date,
                    to_char(plan_end_date, 'MM/DD/YYYY')                               plan_end_date,
                    to_char(open_enrollment_start_date, 'MM/DD/YYYY')                  open_enrollment_start_date,
                    to_char(open_enrollment_end_date, 'MM/DD/YYYY')                    open_enrollment_end_date,
                    to_char(effective_date, 'MM/DD/YYYY')                              effective_date,
                    pc_lookups.get_meaning(status, 'BEN_PLAN_STATUS')                  status,
                    to_char(fiscal_end_date, 'MM/DD/YYYY')                             fiscal_end_date,
                    pc_lookups.get_meaning(takeover, 'YES_NO')                         takeover,
                    to_char(original_eff_date, 'MM/DD/YYYY')                           original_eff_date,
                    to_char(amendment_date, 'MM/DD/YYYY')                              amendment_date,
                    pc_lookups.get_meaning(plan_docs_flag, 'YES_NO')                   plan_docs_flag,
                    pc_lookups.get_meaning(non_discrm_flag, 'YES_NO')                  non_discrm_flag,
                    minimum_election,
                    maximum_election,
                    payroll_contrib,
                    (
                        select
                            meaning
                        from
                            funding_option
                        where
                            lookup_code = funding_options
                    )                                                                  funding_options_old,
                    pc_lookups.get_meaning(rollover, 'YES_NO')                         rollover,
                    decode(new_hire_contrib, 'PRORATE', 'Prorate', 'No')               new_hire_contrib,
                    to_char(effective_end_date, 'MM/DD/YYYY')                          effective_end_date,
                    to_char(termination_req_date, 'MM/DD/YYYY')                        termination_req_date,
                    pc_lookups.get_meaning(term_eligibility, 'YES_NO')                 term_eligibility,
                    runout_period_days,
                    runout_period_term,
                    grace_period,
                    pc_lookups.get_meaning(transaction_period, 'ACC_PAY_PERIOD')       transaction_period,
                    transaction_limit,
                    pc_lookups.get_meaning(iias_enable, 'IIAS_ENABLE')                 iias_enable,
                    pc_lookups.get_meaning(claim_reimbursed_by, 'CLAIM_REIMBURSED_BY') claim_reimbursed_by,
                    to_char(reimburse_start_date, 'MM/DD/YYYY')                        reimburse_start_date,
                    to_char(reimburse_end_date, 'MM/DD/YYYY')                          reimburse_end_date,
                    pc_lookups.get_meaning(allow_substantiation, 'YES_NO')             allow_substantiation,
                    note,
                    acc_id
                from
                    ben_plan_enrollment_setup
                where
                        ben_plan_id = (
                            select
                                max(ben_plan_id)
                            from
                                ben_plan_enrollment_setup
                            where
                                    ben_plan_id != l_ben_plan_new(i).ben_plan_id
                                and acc_id = l_ben_plan_new(i).acc_id
                                and plan_type = l_ben_plan_new(i).plan_type
                        )
                    and rownum = 1
            ) loop
                v_old_data := 'Y';
                v_plan_type := ak.plan_type;
                v_ben_plan_name := ak.ben_plan_name;
                v_plan_start_date := ak.plan_start_date;
                v_plan_end_date := ak.plan_end_date;
                v_open_enr_start_date := ak.open_enrollment_start_date;
                v_open_enr_end_date := ak.open_enrollment_end_date;
                v_effect_date := ak.effective_date;
                v_status := ak.status;
                v_fiscal_end_date := ak.fiscal_end_date;
                v_takeover := ak.takeover;
                v_orig_eff_date := ak.original_eff_date;
                v_amend_date := ak.amendment_date;
                v_plan_docs_flag := ak.plan_docs_flag;
                v_non_discrm_flag := ak.non_discrm_flag;
                v_min_election := ak.minimum_election;
                v_max_election := ak.maximum_election;
                v_payroll_contrib := ak.payroll_contrib;
                v_funding_options_old := ak.funding_options_old;
                v_rollover := ak.rollover;
                v_new_hire_contrib := ak.new_hire_contrib;
                v_effect_end_date := ak.effective_end_date;
                v_term_req_date := ak.termination_req_date;
                v_term_elig := ak.term_eligibility;
                v_runout_period_days := ak.runout_period_days;
                v_runout_period_term := ak.runout_period_term;
                v_grace_period := ak.grace_period;
                v_tran_period := ak.transaction_period;
                v_tran_limit := ak.transaction_limit;
                v_iias_enable := ak.iias_enable;
                v_claim_reimb_by := ak.claim_reimbursed_by;
                v_reimb_start_date := ak.reimburse_start_date;
                v_reimb_end_date := ak.reimburse_end_date;
                v_allow_subst := ak.allow_substantiation;
                v_note := ak.note;
            end loop;

            for k in (
                select
                    meaning
                from
                    funding_option
                where
                    lookup_code = l_ben_plan_new(i).funding_options
            ) loop
                v_funding_options := k.meaning;
            end loop;

            for k in (
                select
                    meaning
                from
                    fsa_hra_plan_type
                where
                    lookup_code = l_ben_plan_new(i).plan_type
            ) loop
                v_plan_type_new := k.meaning;
            end loop;

            gen_xl_xml.set_column_width(1, 135, v_work_sheet);
           --Plan Setup Work sheet Header
            gen_xl_xml.write_cell_char(1, r, v_work_sheet, 'Employer Name(Account Number)', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_char(1,
                                       r + 1,
                                       v_work_sheet,
                                       pc_entrp.get_entrp_name(l_ben_plan_new(i).entrp_id)
                                       || '('
                                       || pc_entrp.get_acc_num(l_ben_plan_new(i).entrp_id)
                                       || ')',
                                       'BEN_PLAN_COLUMN');

            gen_xl_xml.write_cell_null(1, r + 2, v_work_sheet, 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_null(2, r, v_work_sheet, 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
              --GEN_XL_XML.WRITE_CELL_CHAR( 2,  R+1, V_WORK_SHEET , 'Renewed Plan',  'BEN_PLAN_HEADER_BEN_PLAN1' );
                gen_xl_xml.write_cell_null(2, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            else
                gen_xl_xml.write_cell_char(2, r + 1, v_work_sheet, 'Renewed Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
                gen_xl_xml.write_cell_char(2, r + 2, v_work_sheet, 'Previous Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
            end if;

            gen_xl_xml.write_cell_char(3, r, v_work_sheet, 'Plan Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(3, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(4, r, v_work_sheet, 'Plan Type', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(4,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).plan_type,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(v_plan_type_new, 0) != nvl(v_plan_type, 0) then
                    gen_xl_xml.write_cell_char(4, r + 1, v_work_sheet, v_plan_type_new, 'BEN_PLAN_COLUMN_CHG');
                    gen_xl_xml.write_cell_char(4, r + 2, v_work_sheet, v_plan_type, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(4, r + 1, v_work_sheet, v_plan_type_new, 'BEN_PLAN_COLUMN');
                    gen_xl_xml.write_cell_char(4, r + 2, v_work_sheet, v_plan_type, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(5, r, v_work_sheet, 'Plan Name', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(5,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).ben_plan_name,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).ben_plan_name,
                       0) != nvl(v_ben_plan_name, 0) then
                    gen_xl_xml.write_cell_char(5,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ben_plan_name,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(5, r + 2, v_work_sheet, v_ben_plan_name, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(5,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ben_plan_name,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(5, r + 2, v_work_sheet, v_ben_plan_name, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(6, r, v_work_sheet, 'Plan Start Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(6,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).plan_start_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).plan_start_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_plan_start_date, 0) then
                    gen_xl_xml.write_cell_char(6,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).plan_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(6, r + 2, v_work_sheet, v_plan_start_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(6,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).plan_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(6, r + 2, v_work_sheet, v_plan_start_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(7, r, v_work_sheet, 'Plan End Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(7,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).plan_end_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).plan_end_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_plan_end_date, 0) then
                    gen_xl_xml.write_cell_char(7,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).plan_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(7, r + 2, v_work_sheet, v_plan_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(7,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).plan_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(7, r + 2, v_work_sheet, v_plan_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(8, r, v_work_sheet, 'Open Enrollment Start Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(8,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).open_enrollment_start_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).open_enrollment_start_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_open_enr_start_date, 0) then
                    gen_xl_xml.write_cell_char(8,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).open_enrollment_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(8, r + 2, v_work_sheet, v_open_enr_start_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(8,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).open_enrollment_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(8, r + 2, v_work_sheet, v_open_enr_start_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(9, r, v_work_sheet, 'Open Enrollment End Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(9,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).open_enrollment_end_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).open_enrollment_end_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_open_enr_end_date, 0) then
                    gen_xl_xml.write_cell_char(9,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).open_enrollment_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(9, r + 2, v_work_sheet, v_open_enr_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(9,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).open_enrollment_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(9, r + 2, v_work_sheet, v_open_enr_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(10, r, v_work_sheet, 'Effective Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(10,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).effective_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).effective_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_effect_date, 0) then
                    gen_xl_xml.write_cell_char(10,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).effective_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(10, r + 2, v_work_sheet, v_effect_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(10,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).effective_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(10, r + 2, v_work_sheet, v_effect_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(11, r, v_work_sheet, 'Plan Status', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(11,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).status,
                                                                  'BEN_PLAN_STATUS'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).status,
                                           'BEN_PLAN_STATUS'),
                    0
                ) != nvl(v_status, 0) then
                    gen_xl_xml.write_cell_char(11,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).status,
                                                                      'BEN_PLAN_STATUS'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(11, r + 2, v_work_sheet, v_status, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(11,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).status,
                                                                      'BEN_PLAN_STATUS'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(11, r + 2, v_work_sheet, v_status, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(12, r, v_work_sheet, 'Fiscal Year End Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(12,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).fiscal_end_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).fiscal_end_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_fiscal_end_date, 0) then
                    gen_xl_xml.write_cell_char(12,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).fiscal_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(12, r + 2, v_work_sheet, v_fiscal_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(12,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).fiscal_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(12, r + 2, v_work_sheet, v_fiscal_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(13, r, v_work_sheet, 'Take Over/Reinstate Prev Plan', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(13,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).takeover,
                                                                  'YES_NO'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).takeover,
                                           'YES_NO'),
                    0
                ) != nvl(v_takeover, 0) then
                    gen_xl_xml.write_cell_char(13,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).takeover,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(13, r + 2, v_work_sheet, v_takeover, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(13,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).takeover,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(13, r + 2, v_work_sheet, v_takeover, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(14, r, v_work_sheet, 'Original Effective Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(14,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).original_eff_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).original_eff_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_orig_eff_date, 0) then
                    gen_xl_xml.write_cell_char(14,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).original_eff_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(14, r + 2, v_work_sheet, v_orig_eff_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(14,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).original_eff_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(14, r + 2, v_work_sheet, v_orig_eff_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(15, r, v_work_sheet, 'Amendment Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(15,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).amendment_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).amendment_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_amend_date, 0) then
                    gen_xl_xml.write_cell_char(15,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).amendment_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(15, r + 2, v_work_sheet, v_amend_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(15,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).amendment_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(15, r + 2, v_work_sheet, v_amend_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(16, r, v_work_sheet, 'Plan Doc ONLY', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(16,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).plan_docs_flag,
                                                                  'YES_NO'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).plan_docs_flag,
                                           'YES_NO'),
                    0
                ) != nvl(v_plan_docs_flag, 0) then
                    gen_xl_xml.write_cell_char(16,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).plan_docs_flag,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(16, r + 2, v_work_sheet, v_plan_docs_flag, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(16,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).plan_docs_flag,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(16, r + 2, v_work_sheet, v_plan_docs_flag, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(17, r, v_work_sheet, 'Non Discrim Testing', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(17,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).non_discrm_flag,
                                                                  'YES_NO'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).non_discrm_flag,
                                           'YES_NO'),
                    0
                ) != nvl(v_non_discrm_flag, 0) then
                    gen_xl_xml.write_cell_char(17,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).non_discrm_flag,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(17, r + 2, v_work_sheet, v_non_discrm_flag, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(17,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).non_discrm_flag,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(17, r + 2, v_work_sheet, v_non_discrm_flag, 'BEN_PLAN_COLUMN');
                end if;
            end if;
           --Annual Election :PAYROLL Setup Work sheet Header
            gen_xl_xml.write_cell_char(18, r, v_work_sheet, 'Annual Election :PAYROLL Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(18, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(19, r, v_work_sheet, 'Min Annual Election', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(19,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).minimum_election,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).minimum_election,
                       -1) != nvl(v_min_election, -1) then
                    gen_xl_xml.write_cell_num(19,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).minimum_election,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(19, r + 2, v_work_sheet, v_min_election, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(19,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).minimum_election,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(19, r + 2, v_work_sheet, v_min_election, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(20, r, v_work_sheet, 'Max Annual Election', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(20,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).maximum_election,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).maximum_election,
                       -1) != nvl(v_max_election, -1) then
                    gen_xl_xml.write_cell_num(20,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).maximum_election,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(20, r + 2, v_work_sheet, v_max_election, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(20,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).maximum_election,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(20, r + 2, v_work_sheet, v_max_election, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(21, r, v_work_sheet, 'Payroll Contribution', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(21,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).payroll_contrib,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).payroll_contrib,
                       -1) != nvl(v_payroll_contrib, -1) then
                    gen_xl_xml.write_cell_num(21,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).payroll_contrib,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(21, r + 2, v_work_sheet, v_payroll_contrib, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(21,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).payroll_contrib,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(21, r + 2, v_work_sheet, v_payroll_contrib, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(22, r, v_work_sheet, 'Funding Options', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(22, r + 1, v_work_sheet, v_funding_options, 'BEN_PLAN_COLUMN');
            else
                if nvl(v_funding_options, 0) != nvl(v_funding_options_old, 0) then
                    gen_xl_xml.write_cell_char(22, r + 1, v_work_sheet, v_funding_options, 'BEN_PLAN_COLUMN_CHG');
                    gen_xl_xml.write_cell_char(22, r + 2, v_work_sheet, v_funding_options_old, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(22, r + 1, v_work_sheet, v_funding_options, 'BEN_PLAN_COLUMN');
                    gen_xl_xml.write_cell_char(22, r + 2, v_work_sheet, v_funding_options_old, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(23, r, v_work_sheet, 'Rollover', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(23,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).rollover,
                                                                  'YES_NO'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).rollover,
                                           'YES_NO'),
                    0
                ) != nvl(v_rollover, 0) then
                    gen_xl_xml.write_cell_char(23,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).rollover,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(23, r + 2, v_work_sheet, v_rollover, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(23,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).rollover,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(23, r + 2, v_work_sheet, v_rollover, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(24, r, v_work_sheet, 'New Hire Contribution', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(24,
                                           r + 1,
                                           v_work_sheet,
                                           case
                                        when l_ben_plan_new(i).new_hire_contrib = 'PRORATE' then
                                            'Prorate'
                                        else 'No'
                                    end,
                                           'BEN_PLAN_COLUMN');
            else
                if case
                    when l_ben_plan_new(i).new_hire_contrib = 'PRORATE' then
                        'Prorate'
                    else 'No'
                end != nvl(v_new_hire_contrib, 'No') then
                    gen_xl_xml.write_cell_char(24,
                                               r + 1,
                                               v_work_sheet,
                                               case
                                            when l_ben_plan_new(i).new_hire_contrib = 'PRORATE' then
                                                'Prorate'
                                            else 'No'
                                        end,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(24, r + 2, v_work_sheet, v_new_hire_contrib, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(24,
                                               r + 1,
                                               v_work_sheet,
                                               case
                                            when l_ben_plan_new(i).new_hire_contrib = 'PRORATE' then
                                                'Prorate'
                                            else 'No'
                                        end,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(24, r + 2, v_work_sheet, v_new_hire_contrib, 'BEN_PLAN_COLUMN');
                end if;
            end if;

           --Termination Setup Work sheet Header
            gen_xl_xml.write_cell_char(25, r, v_work_sheet, 'Termination Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(25, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(26, r, v_work_sheet, 'Termination Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(26,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).effective_end_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).effective_end_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_effect_end_date, 0) then
                    gen_xl_xml.write_cell_char(26,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).effective_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(26, r + 2, v_work_sheet, v_effect_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(26,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).effective_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(26, r + 2, v_work_sheet, v_effect_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(27, r, v_work_sheet, 'Termination Request Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(27,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).termination_req_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).termination_req_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_term_req_date, 0) then
                    gen_xl_xml.write_cell_char(27,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).termination_req_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(27, r + 2, v_work_sheet, v_term_req_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(27,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).termination_req_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(27, r + 2, v_work_sheet, v_term_req_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(28, r, v_work_sheet, 'Term Eligibility', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(28,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).term_eligibility,
                                                                  'YES_NO'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).term_eligibility,
                                           'YES_NO'),
                    0
                ) != nvl(v_term_elig, 0) then
                    gen_xl_xml.write_cell_char(28,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).term_eligibility,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(28, r + 2, v_work_sheet, v_term_elig, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(28,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).term_eligibility,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(28, r + 2, v_work_sheet, v_term_elig, 'BEN_PLAN_COLUMN');
                end if;
            end if;

           --Grace :RUNOUT Setup Header
            gen_xl_xml.write_cell_char(29, r, v_work_sheet, 'Grace :RUNOUT Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(29, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(30, r, v_work_sheet, 'Runout Period Days', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(30,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).runout_period_days,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).runout_period_days,
                       -1) != nvl(v_runout_period_days, -1) then
                    gen_xl_xml.write_cell_num(30,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).runout_period_days,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(30, r + 2, v_work_sheet, v_runout_period_days, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(30,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).runout_period_days,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(30, r + 2, v_work_sheet, v_runout_period_days, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(31, r, v_work_sheet, 'Runout Period Term', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(31,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).runout_period_term,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).runout_period_term,
                       0) != nvl(v_runout_period_term, 0) then
                    gen_xl_xml.write_cell_char(31,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).runout_period_term,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(31, r + 2, v_work_sheet, v_runout_period_term, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(31,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).runout_period_term,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(31, r + 2, v_work_sheet, v_runout_period_term, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(32, r, v_work_sheet, 'Grace Period', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(32,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).grace_period,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).grace_period,
                       -1) != nvl(v_grace_period, -1) then
                    gen_xl_xml.write_cell_num(32,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).grace_period,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(32, r + 2, v_work_sheet, v_grace_period, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(32,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).grace_period,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(32, r + 2, v_work_sheet, v_grace_period, 'BEN_PLAN_COLUMN');
                end if;
            end if;

           --Reimbursement Setup Header
            gen_xl_xml.write_cell_char(33, r, v_work_sheet, 'Reimbursement Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(33, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(34, r, v_work_sheet, 'Transaction Period', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(34,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).transaction_period,
                                                                  'ACC_PAY_PERIOD'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).transaction_period,
                                           'ACC_PAY_PERIOD'),
                    0
                ) != nvl(v_tran_period, 0) then
                    gen_xl_xml.write_cell_char(34,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).transaction_period,
                                                                      'ACC_PAY_PERIOD'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(34, r + 2, v_work_sheet, v_tran_period, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(34,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).transaction_period,
                                                                      'ACC_PAY_PERIOD'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(34, r + 2, v_work_sheet, v_tran_period, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(35, r, v_work_sheet, 'Transaction Limit', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(35,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).transaction_limit,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).transaction_limit,
                       0) != nvl(v_tran_limit, 0) then
                    gen_xl_xml.write_cell_char(35,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).transaction_limit,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(35, r + 2, v_work_sheet, v_tran_limit, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(35,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).transaction_limit,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(35, r + 2, v_work_sheet, v_tran_limit, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(36, r, v_work_sheet, 'IIAS Enable', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(36,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).iias_enable,
                                                                  'IIAS_ENABLE'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).iias_enable,
                                           'IIAS_ENABLE'),
                    0
                ) != nvl(v_iias_enable, 0) then
                    gen_xl_xml.write_cell_char(36,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).iias_enable,
                                                                      'IIAS_ENABLE'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(36, r + 2, v_work_sheet, v_iias_enable, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(36,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).iias_enable,
                                                                      'IIAS_ENABLE'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(36, r + 2, v_work_sheet, v_iias_enable, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(37, r, v_work_sheet, 'Claim Reimbursed By', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(37,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).claim_reimbursed_by,
                                                                  'CLAIM_REIMBURSED_BY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).claim_reimbursed_by,
                                           'CLAIM_REIMBURSED_BY'),
                    0
                ) != nvl(v_claim_reimb_by, 0) then
                    gen_xl_xml.write_cell_char(37,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).claim_reimbursed_by,
                                                                      'CLAIM_REIMBURSED_BY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(37, r + 2, v_work_sheet, v_claim_reimb_by, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(37,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).claim_reimbursed_by,
                                                                      'CLAIM_REIMBURSED_BY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(37, r + 2, v_work_sheet, v_claim_reimb_by, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(38, r, v_work_sheet, 'Reimburse Start Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(38,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).reimburse_start_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).reimburse_start_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_reimb_start_date, 0) then
                    gen_xl_xml.write_cell_char(38,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).reimburse_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(38, r + 2, v_work_sheet, v_reimb_start_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(38,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).reimburse_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(38, r + 2, v_work_sheet, v_reimb_start_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(39, r, v_work_sheet, 'Reimburse End Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(39,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).reimburse_end_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).reimburse_end_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_reimb_end_date, 0) then
                    gen_xl_xml.write_cell_char(39,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).reimburse_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(39, r + 2, v_work_sheet, v_reimb_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(39,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).reimburse_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(39, r + 2, v_work_sheet, v_reimb_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(40, r, v_work_sheet, 'Allow Substantiation', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(40,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).allow_substantiation,
                                                                  'YES_NO'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).allow_substantiation,
                                           'YES_NO'),
                    0
                ) != nvl(v_allow_subst, 0) then
                    gen_xl_xml.write_cell_char(40,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).allow_substantiation,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(40, r + 2, v_work_sheet, v_allow_subst, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(40,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).allow_substantiation,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(40, r + 2, v_work_sheet, v_allow_subst, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(41, r, v_work_sheet, 'Note', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(41,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).note,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).note,
                       0) != nvl(v_note, 0) then
                    gen_xl_xml.write_cell_char(41,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).note,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(41, r + 2, v_work_sheet, v_note, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(41,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).note,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(41, r + 2, v_work_sheet, v_note, 'BEN_PLAN_COLUMN');
                end if;
            end if;

        end loop;

        for j in 1..l_ben_plan_renew_new.count loop
            v_old_data := 'N';
            v_start := 'N';
            v_entrp_id := null;
            v_funding_options := null;
            r := 1;
            v_work_sheet := pc_account.get_acc_num_from_acc_id(l_ben_plan_renew_new(j).acc_id)
                            || '-'
                            || l_ben_plan_renew_new(j).plan_type;

            v_plan_type := null;
            v_ben_plan_name := null;
            v_plan_start_date := null;
            v_plan_end_date := null;
            v_open_enr_start_date := null;
            v_open_enr_end_date := null;
            v_effect_date := null;
            v_status := null;
            v_fiscal_end_date := null;
            v_takeover := null;
            v_orig_eff_date := null;
            v_amend_date := null;
            v_plan_docs_flag := null;
            v_non_discrm_flag := null;
            v_min_election := null;
            v_max_election := null;
            v_payroll_contrib := null;
            v_funding_options_old := null;
            v_rollover := null;
            v_new_hire_contrib := null;
            v_effect_end_date := null;
            v_term_req_date := null;
            v_term_elig := null;
            v_runout_period_days := null;
            v_runout_period_term := null;
            v_grace_period := null;
            v_tran_period := null;
            v_tran_limit := null;
            v_iias_enable := null;
            v_claim_reimb_by := null;
            v_reimb_start_date := null;
            v_reimb_end_date := null;
            v_allow_subst := null;
            v_note := null;
            v_start_date_old := null;
            v_end_date_old := null;
            v_count_other_fsa := 0;
            select
                count(*)
            into v_count_other_fsa
            from
                ben_plan_renewals
            where
                    plan_type = l_ben_plan_renew_new(j).plan_type
                and ben_plan_id = l_ben_plan_renew_new(j).ben_plan_id;

            if v_count_other_fsa > 1 then
                for p in (
                    select
                        start_date,
                        end_date
                    from
                        ben_plan_renewals
                    where
                        ben_plan_id = l_ben_plan_renew_new(j).ben_plan_id
                           /*AND EXTRACT(YEAR FROM START_DATE) = EXTRACT(YEAR FROM SYSDATE)-1*/
                ) loop
                    v_start_date_old := to_char(p.start_date, 'MM/DD/YYYY');
                    v_end_date_old := to_char(p.end_date, 'MM/DD/YYYY');
                end loop;
            end if;

            for ak in (
                select
                    (
                        select
                            meaning
                        from
                            fsa_hra_plan_type
                        where
                            lookup_code = plan_type
                    )                                                                  plan_type,
                    ben_plan_name,
                    to_char(plan_start_date, 'MM/DD/YYYY')                             plan_start_date,
                    to_char(plan_end_date, 'MM/DD/YYYY')                               plan_end_date,
                    to_char(open_enrollment_start_date, 'MM/DD/YYYY')                  open_enrollment_start_date,
                    to_char(open_enrollment_end_date, 'MM/DD/YYYY')                    open_enrollment_end_date,
                    to_char(effective_date, 'MM/DD/YYYY')                              effective_date,
                    pc_lookups.get_meaning(status, 'BEN_PLAN_STATUS')                  status,
                    to_char(fiscal_end_date, 'MM/DD/YYYY')                             fiscal_end_date,
                    pc_lookups.get_meaning(takeover, 'YES_NO')                         takeover,
                    to_char(original_eff_date, 'MM/DD/YYYY')                           original_eff_date,
                    to_char(amendment_date, 'MM/DD/YYYY')                              amendment_date,
                    pc_lookups.get_meaning(plan_docs_flag, 'YES_NO')                   plan_docs_flag,
                    pc_lookups.get_meaning(non_discrm_flag, 'YES_NO')                  non_discrm_flag,
                    minimum_election,
                    maximum_election,
                    payroll_contrib,
                    (
                        select
                            meaning
                        from
                            funding_option
                        where
                            lookup_code = funding_options
                    )                                                                  funding_options_old,
                    pc_lookups.get_meaning(rollover, 'YES_NO')                         rollover,
                    decode(new_hire_contrib, 'PRORATE', 'Prorate', 'No')               new_hire_contrib,
                    to_char(effective_end_date, 'MM/DD/YYYY')                          effective_end_date,
                    to_char(termination_req_date, 'MM/DD/YYYY')                        termination_req_date,
                    pc_lookups.get_meaning(term_eligibility, 'YES_NO')                 term_eligibility,
                    runout_period_days,
                    runout_period_term,
                    grace_period,
                    pc_lookups.get_meaning(transaction_period, 'ACC_PAY_PERIOD')       transaction_period,
                    transaction_limit,
                    pc_lookups.get_meaning(iias_enable, 'IIAS_ENABLE')                 iias_enable,
                    pc_lookups.get_meaning(claim_reimbursed_by, 'CLAIM_REIMBURSED_BY') claim_reimbursed_by,
                    to_char(reimburse_start_date, 'MM/DD/YYYY')                        reimburse_start_date,
                    to_char(reimburse_end_date, 'MM/DD/YYYY')                          reimburse_end_date,
                    pc_lookups.get_meaning(allow_substantiation, 'YES_NO')             allow_substantiation,
                    note,
                    entrp_id
                from
                    ben_plan_enrollment_setup
                where
                        ben_plan_id = l_ben_plan_renew_new(j).ben_plan_id
                    and rownum = 1
            ) loop
                v_old_data := 'Y';
                v_plan_type := ak.plan_type;
                v_ben_plan_name := ak.ben_plan_name;
                v_plan_start_date := ak.plan_start_date;
                v_plan_end_date := ak.plan_end_date;
                v_open_enr_start_date := ak.open_enrollment_start_date;
                v_open_enr_end_date := ak.open_enrollment_end_date;
                v_effect_date := ak.effective_date;
                v_status := ak.status;
                v_fiscal_end_date := ak.fiscal_end_date;
                v_takeover := ak.takeover;
                v_orig_eff_date := ak.original_eff_date;
                v_amend_date := ak.amendment_date;
                v_plan_docs_flag := ak.plan_docs_flag;
                v_non_discrm_flag := ak.non_discrm_flag;
                v_min_election := ak.minimum_election;
                v_max_election := ak.maximum_election;
                v_payroll_contrib := ak.payroll_contrib;
                v_funding_options_old := ak.funding_options_old;
                v_rollover := ak.rollover;
                v_new_hire_contrib := ak.new_hire_contrib;
                v_effect_end_date := ak.effective_end_date;
                v_term_req_date := ak.termination_req_date;
                v_term_elig := ak.term_eligibility;
                v_runout_period_days := ak.runout_period_days;
                v_runout_period_term := ak.runout_period_term;
                v_grace_period := ak.grace_period;
                v_tran_period := ak.transaction_period;
                v_tran_limit := ak.transaction_limit;
                v_iias_enable := ak.iias_enable;
                v_claim_reimb_by := ak.claim_reimbursed_by;
                v_reimb_start_date := ak.reimburse_start_date;
                v_reimb_end_date := ak.reimburse_end_date;
                v_allow_subst := ak.allow_substantiation;
                v_note := ak.note;
                v_entrp_id := ak.entrp_id;
            end loop;

            gen_xl_xml.set_column_width(1, 135, v_work_sheet);
           --Plan Setup Work sheet Header

            gen_xl_xml.write_cell_char(1, r, v_work_sheet, 'Employer Name(Account Number)', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_char(1,
                                       r + 1,
                                       v_work_sheet,
                                       pc_entrp.get_entrp_name(v_entrp_id)
                                       || '('
                                       || pc_entrp.get_acc_num(v_entrp_id)
                                       || ')',
                                       'BEN_PLAN_COLUMN');

            gen_xl_xml.write_cell_null(1, r + 2, v_work_sheet, 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_null(2, r, v_work_sheet, 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(2, r + 1, v_work_sheet, 'Renewed Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
            gen_xl_xml.write_cell_char(2, r + 2, v_work_sheet, 'Previous Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
            gen_xl_xml.write_cell_char(3, r, v_work_sheet, 'Plan Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(3, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(4, r, v_work_sheet, 'Plan Type', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(4, r + 1, v_work_sheet, v_plan_type, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(4, r + 2, v_work_sheet, v_plan_type, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(5, r, v_work_sheet, 'Plan Name', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(5, r + 1, v_work_sheet, v_ben_plan_name, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(5, r + 2, v_work_sheet, v_ben_plan_name, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(6, r, v_work_sheet, 'Plan Start Date', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(6,
                                       r + 1,
                                       v_work_sheet,
                                       to_char(l_ben_plan_renew_new(j).start_date,
                                               'MM/DD/YYYY'),
                                       'BEN_PLAN_COLUMN_CHG');

            gen_xl_xml.write_cell_char(6,
                                       r + 2,
                                       v_work_sheet,
                                       nvl(v_start_date_old, v_plan_start_date),
                                       'BEN_PLAN_COLUMN_CHG');

            gen_xl_xml.write_cell_char(7, r, v_work_sheet, 'Plan End Date', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(7,
                                       r + 1,
                                       v_work_sheet,
                                       to_char(l_ben_plan_renew_new(j).end_date,
                                               'MM/DD/YYYY'),
                                       'BEN_PLAN_COLUMN_CHG');

            gen_xl_xml.write_cell_char(7,
                                       r + 2,
                                       v_work_sheet,
                                       nvl(v_end_date_old, v_plan_end_date),
                                       'BEN_PLAN_COLUMN_CHG');

            gen_xl_xml.write_cell_char(8, r, v_work_sheet, 'Open Enrollment Start Date', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(8, r + 1, v_work_sheet, v_open_enr_start_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(8, r + 2, v_work_sheet, v_open_enr_start_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(9, r, v_work_sheet, 'Open Enrollment End Date', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(9, r + 1, v_work_sheet, v_open_enr_end_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(9, r + 2, v_work_sheet, v_open_enr_end_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(10, r, v_work_sheet, 'Effective Date', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(10, r + 1, v_work_sheet, v_effect_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(10, r + 2, v_work_sheet, v_effect_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(11, r, v_work_sheet, 'Plan Status', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(11, r + 1, v_work_sheet, v_status, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(11, r + 2, v_work_sheet, v_status, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(12, r, v_work_sheet, 'Fiscal Year End Date', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(12, r + 1, v_work_sheet, v_fiscal_end_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(12, r + 2, v_work_sheet, v_fiscal_end_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(13, r, v_work_sheet, 'Take Over/Reinstate Prev Plan', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(13, r + 1, v_work_sheet, v_takeover, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(13, r + 2, v_work_sheet, v_takeover, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(14, r, v_work_sheet, 'Original Effective Date', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(14, r + 1, v_work_sheet, v_orig_eff_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(14, r + 2, v_work_sheet, v_orig_eff_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(15, r, v_work_sheet, 'Amendment Date', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(15, r + 1, v_work_sheet, v_amend_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(15, r + 2, v_work_sheet, v_amend_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(16, r, v_work_sheet, 'Plan Doc ONLY', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(16, r + 1, v_work_sheet, v_plan_docs_flag, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(16, r + 2, v_work_sheet, v_plan_docs_flag, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(17, r, v_work_sheet, 'Non Discrim Testing', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(17, r + 1, v_work_sheet, v_non_discrm_flag, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(17, r + 2, v_work_sheet, v_non_discrm_flag, 'BEN_PLAN_COLUMN');

           --Annual Election :PAYROLL Setup Work sheet Header
            gen_xl_xml.write_cell_char(18, r, v_work_sheet, 'Annual Election :PAYROLL Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(18, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(19, r, v_work_sheet, 'Min Annual Election', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_num(19, r + 1, v_work_sheet, v_min_election, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_num(19, r + 2, v_work_sheet, v_min_election, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(20, r, v_work_sheet, 'Max Annual Election', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_num(20, r + 1, v_work_sheet, v_max_election, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_num(20, r + 2, v_work_sheet, v_max_election, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(21, r, v_work_sheet, 'Payroll Contribution', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_num(21, r + 1, v_work_sheet, v_payroll_contrib, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_num(21, r + 2, v_work_sheet, v_payroll_contrib, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(22, r, v_work_sheet, 'Funding Options', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(22, r + 1, v_work_sheet, v_funding_options, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(22, r + 2, v_work_sheet, v_funding_options, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(23, r, v_work_sheet, 'Rollover', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(23, r + 1, v_work_sheet, v_rollover, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(23, r + 2, v_work_sheet, v_rollover, 'BEN_PLAN_COLUMN');
            dbms_output.put_line('In Loop211..');
            gen_xl_xml.write_cell_char(24, r, v_work_sheet, 'New Hire Contribution', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(24, r + 1, v_work_sheet, v_new_hire_contrib, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(24, r + 2, v_work_sheet, v_new_hire_contrib, 'BEN_PLAN_COLUMN');

           --Termination Setup Work sheet Header
            gen_xl_xml.write_cell_char(25, r, v_work_sheet, 'Termination Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(25, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            dbms_output.put_line('In Loop3..');
            gen_xl_xml.write_cell_char(26, r, v_work_sheet, 'Termination Date', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(26, r + 1, v_work_sheet, v_effect_end_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(26, r + 2, v_work_sheet, v_effect_end_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(27, r, v_work_sheet, 'Termination Request Date', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(27, r + 1, v_work_sheet, v_term_req_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(27, r + 2, v_work_sheet, v_term_req_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(28, r, v_work_sheet, 'Term Eligibility', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(28, r + 1, v_work_sheet, v_term_elig, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(28, r + 2, v_work_sheet, v_term_elig, 'BEN_PLAN_COLUMN');

           --Grace :RUNOUT Setup Header
            gen_xl_xml.write_cell_char(29, r, v_work_sheet, 'Grace :RUNOUT Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(29, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(30, r, v_work_sheet, 'Runout Period Days', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_num(30, r + 1, v_work_sheet, v_runout_period_days, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_num(30, r + 2, v_work_sheet, v_runout_period_days, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(31, r, v_work_sheet, 'Runout Period Term', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(31, r + 1, v_work_sheet, v_runout_period_term, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(31, r + 2, v_work_sheet, v_runout_period_term, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(32, r, v_work_sheet, 'Grace Period', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_num(32, r + 1, v_work_sheet, v_grace_period, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_num(32, r + 2, v_work_sheet, v_grace_period, 'BEN_PLAN_COLUMN');

           --Reimbursement Setup Header
            gen_xl_xml.write_cell_char(33, r, v_work_sheet, 'Reimbursement Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(33, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            dbms_output.put_line('In Loop4..');
            gen_xl_xml.write_cell_char(34, r, v_work_sheet, 'Transaction Period', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(34, r + 1, v_work_sheet, v_tran_period, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(34, r + 2, v_work_sheet, v_tran_period, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(35, r, v_work_sheet, 'Transaction Limit', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(35, r + 1, v_work_sheet, v_tran_limit, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(35, r + 2, v_work_sheet, v_tran_limit, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(36, r, v_work_sheet, 'IIAS Enable', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(36, r + 1, v_work_sheet, v_iias_enable, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(36, r + 2, v_work_sheet, v_iias_enable, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(37, r, v_work_sheet, 'Claim Reimbursed By', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(37, r + 1, v_work_sheet, v_claim_reimb_by, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(37, r + 2, v_work_sheet, v_claim_reimb_by, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(38, r, v_work_sheet, 'Reimburse Start Date', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(38, r + 1, v_work_sheet, v_reimb_start_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(38, r + 2, v_work_sheet, v_reimb_start_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(39, r, v_work_sheet, 'Reimburse End Date', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(39, r + 1, v_work_sheet, v_reimb_end_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(39, r + 2, v_work_sheet, v_reimb_end_date, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(40, r, v_work_sheet, 'Allow Substantiation', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(40, r + 1, v_work_sheet, v_allow_subst, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(40, r + 2, v_work_sheet, v_allow_subst, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(41, r, v_work_sheet, 'Note', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(41, r + 1, v_work_sheet, v_note, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(41, r + 2, v_work_sheet, v_note, 'BEN_PLAN_COLUMN');
        end loop;

        dbms_output.put_line('In Loop5..');
        if l_ben_plan_new.count > 0
        or l_ben_plan_renew_new.count > 0 then
            gen_xl_xml.close_file;
        end if;

        v_email := 'IT-team@sterlingadministration.com';
        dbms_output.put_line('Filename..Loop out..' || v_file_name);
        if file_exists(v_file_name, 'MAILER_DIR') = 'TRUE' then
            dbms_output.put_line('Email..' || v_email);
            v_html_msg := '<html><body><br>
                  <p>Daily FSA Renewal Changes Report for the Date '
                          || to_char(sysdate, 'MM/DD/YYYY')
                          || ' </p> <br> <br>
                   </body></html>';
            if user = 'SAM' then
                v_email := 'clientservices@sterlingadministration.com,Renewals@sterlingadministration.com'
                           || ',dan.tidball@sterlingadministration.com,DL_Sales@sterlingadministration.com'
                           || ',sarah.soman@sterlingadministration.com,IT-Team@sterlingadministration.com'
                           || ',VHSTeam@sterlingadministration.com';
            else
                v_email := 'IT-team@sterlingadministration.com';
                dbms_output.put_line('Email..Else..' || v_email);
            end if;

       --IF P_ACC_ID IS  NULL THEN
            mail_utility.send_file_in_emails(
                p_from_email   => 'oracle@sterlinghsa.com',
                p_to_email     => v_email,
                p_file_name    => v_file_name,
                p_sql          => null,
                p_html_message => v_html_msg,
                p_report_title => 'Daily FSA Renewal Changes Report for the Date ' || to_char(sysdate, 'MM/DD/YYYY')
            );
      ---END IF;
            if p_acc_id is not null then
                pc_crm_interface.export_changes_report(p_acc_id, v_file_name);
            end if;
        end if;

    exception
        when no_data_found then
            dbms_output.put_line('ERROR '
                                 || ' '
                                 || sqlerrm
                                 || ' '
                                 || sqlcode);
        when others then
            dbms_output.put_line('ERROR '
                                 || ' '
                                 || sqlerrm
                                 || ' '
                                 || sqlcode);
    end pos_renewal_det_fsa;

    procedure pos_renewal_det_hra (
        p_acc_id in number default null
    ) is

        type rec_ben_plan_setup is
            table of ben_plan_enrollment_setup%rowtype;
        type rec_worksheet is record (
            work_book varchar2(4000)
        );
        type tbl_worksheet is
            table of rec_worksheet;



       --- 5517 ADDED BY RPRABU ON 16/04/2018
        type rec_coverage_type is
            table of coverage_type_rec;

       -- 5517 ADDED BY RPRABU ON 16/04/2018
        l_coverage_code_old   rec_coverage_type;
        l_coverage_code       rec_coverage_type;
        v_ben_plan_id_old     varchar2(100); --- 5517 ADDED BY RPRABU ON 16/04/2018
        l_line_no             number := 0; --- rprabu 16/04/2018 5517

        l_ben_plan_new        rec_ben_plan_setup;
        l_worksheet           rec_worksheet;
        v_start               varchar2(1) := 'Y';
        v_old_data            varchar2(1);
        v_file_id             number;
        v_funding_options     varchar2(4000);
        v_funding_options_old varchar2(4000);
        v_work_sheet          varchar2(4000);
        v_file_name           varchar2(4000);
        r                     number := 0;
        v_plan_type           varchar2(100);
        v_ben_plan_name       varchar2(100);
        v_plan_start_date     varchar2(100);
        v_plan_end_date       varchar2(100);
        v_open_enr_start_date varchar2(100);
        v_open_enr_end_date   varchar2(100);
        v_effect_date         varchar2(100);
        v_status              varchar2(100);
        v_fiscal_end_date     varchar2(100);
        v_takeover            varchar2(100);
        v_orig_eff_date       varchar2(100);
        v_amend_date          varchar2(100);
        v_plan_docs_flag      varchar2(100);
        v_non_discrm_flag     varchar2(100);
        v_min_election        number;
        v_max_election        number;
        v_payroll_contrib     number;
        v_rollover            varchar2(100);
        v_new_hire_contrib    varchar2(100);
        v_effect_end_date     varchar2(100);
        v_term_req_date       varchar2(100);
        v_term_elig           varchar2(100);
        v_plan_type_new       varchar2(100);
        v_runout_period_days  number;
        v_runout_period_term  varchar2(100);
        v_grace_period        number;
        v_tran_period         varchar2(100);
        v_tran_limit          varchar2(100);
        v_iias_enable         varchar2(100);
        v_claim_reimb_by      varchar2(100);
        v_reimb_start_date    varchar2(100);
        v_reimb_end_date      varchar2(100);
        v_allow_subst         varchar2(100);
        v_note                varchar2(4000);
        v_html_msg            varchar2(4000);
        v_email               varchar2(4000);
    begin
        select
            *
        bulk collect
        into l_ben_plan_new
        from
            (
                select
                    *
                from
                    ben_plan_enrollment_setup a
                where
                        trunc(creation_date) > trunc(sysdate) - 1
                    and entrp_id is not null
                    and product_type = 'HRA'
                    and exists (
                        select
                            1
                        from
                            ben_plan_enrollment_setup b
                        where
                                b.ben_plan_id != a.ben_plan_id
                            and b.acc_id = a.acc_id
                            and b.plan_type = a.plan_type
                    )
                union
                select
                    *
                from
                    ben_plan_enrollment_setup a
                where
                        acc_id = p_acc_id
                    and plan_start_date > sysdate
                    and entrp_id is not null
                    and product_type = 'HRA'
                    and exists (
                        select
                            1
                        from
                            ben_plan_enrollment_setup b
                        where
                                b.ben_plan_id != a.ben_plan_id
                            and b.acc_id = a.acc_id
                            and b.plan_type = a.plan_type
                    )
            );

        for i in 1..l_ben_plan_new.count loop
            if v_start = 'Y' then
                v_file_id := pc_file_upload.insert_file_seq('DAILY_RENEWAL_BEN_PLAN_HRA');
                v_file_name := 'HRA_Renewal_Changes_Report_'
                               || v_file_id
                               || '_'
                               || to_char(sysdate, 'YYYYMMDDHH24MISS')
                               || '.xls';

              --GEN_XL_XML.CREATE_EXCEL( 'DAILY_RENEWAL_POP_ERISA',V_FILE_NAME) ;
                gen_xl_xml.create_excel('MAILER_DIR', v_file_name);
                gen_xl_xml.create_style('BEN_PLAN_HEADER', 'Calibri', 'Black', 10,
                                        p_bold => true);
                gen_xl_xml.create_style('BEN_PLAN_HEADER_BEN_PLAN', 'Calibri', 'Red', 10,
                                        p_bold => true);
                gen_xl_xml.create_style('BEN_PLAN_HEADER_BEN_PLAN1', 'Calibri', 'Blue', 10,
                                        p_bold => true);
                gen_xl_xml.create_style('BEN_PLAN_COLUMN', 'Calibri', 'Black', 9);
                gen_xl_xml.create_style('BEN_PLAN_COLUMN_CHG', 'Calibri', 'Green', 9,
                                        p_backcolor => 'Yellow');
                for ik in 1..l_ben_plan_new.count loop
                    l_worksheet.work_book := pc_entrp.get_acc_num(l_ben_plan_new(ik).entrp_id)
                                             || '-'
                                             || l_ben_plan_new(ik).plan_type;

                    gen_xl_xml.create_worksheet(l_worksheet.work_book);
                    v_work_sheet := l_worksheet.work_book;
                end loop;

            end if;

            v_old_data := 'N';
            v_start := 'N';
            v_funding_options := null;
            r := 1;
            v_work_sheet := pc_entrp.get_acc_num(l_ben_plan_new(i).entrp_id)
                            || '-'
                            || l_ben_plan_new(i).plan_type;

            v_plan_type := null;
            v_ben_plan_name := null;
            v_plan_start_date := null;
            v_plan_end_date := null;
            v_open_enr_start_date := null;
            v_open_enr_end_date := null;
            v_effect_date := null;
            v_status := null;
            v_fiscal_end_date := null;
            v_takeover := null;
            v_orig_eff_date := null;
            v_amend_date := null;
            v_plan_docs_flag := null;
            v_non_discrm_flag := null;
            v_min_election := null;
            v_max_election := null;
            v_payroll_contrib := null;
            v_funding_options_old := null;
            v_rollover := null;
            v_new_hire_contrib := null;
            v_effect_end_date := null;
            v_term_req_date := null;
            v_term_elig := null;
            v_runout_period_days := null;
            v_runout_period_term := null;
            v_grace_period := null;
            v_tran_period := null;
            v_tran_limit := null;
            v_iias_enable := null;
            v_claim_reimb_by := null;
            v_reimb_start_date := null;
            v_reimb_end_date := null;
            v_allow_subst := null;
            v_note := null;
            for ak in (
                select
                    (
                        select
                            meaning
                        from
                            fsa_hra_plan_type
                        where
                            lookup_code = plan_type
                    )                                                                  plan_type,
                    ben_plan_name,
                    ben_plan_id,  --- rprabu 16/04/2018 5517
                    to_char(plan_start_date, 'MM/DD/YYYY')                             plan_start_date,
                    to_char(plan_end_date, 'MM/DD/YYYY')                               plan_end_date,
                    to_char(open_enrollment_start_date, 'MM/DD/YYYY')                  open_enrollment_start_date,
                    to_char(open_enrollment_end_date, 'MM/DD/YYYY')                    open_enrollment_end_date,
                    to_char(effective_date, 'MM/DD/YYYY')                              effective_date,
                    pc_lookups.get_meaning(status, 'BEN_PLAN_STATUS')                  status,
                    to_char(fiscal_end_date, 'MM/DD/YYYY')                             fiscal_end_date,
                    pc_lookups.get_meaning(takeover, 'YES_NO')                         takeover,
                    to_char(original_eff_date, 'MM/DD/YYYY')                           original_eff_date,
                    to_char(amendment_date, 'MM/DD/YYYY')                              amendment_date,
                    pc_lookups.get_meaning(plan_docs_flag, 'YES_NO')                   plan_docs_flag,
                    pc_lookups.get_meaning(non_discrm_flag, 'YES_NO')                  non_discrm_flag,
                    minimum_election,
                    maximum_election,
                    payroll_contrib,
                    (
                        select
                            meaning
                        from
                            funding_option
                        where
                            lookup_code = funding_options
                    )                                                                  funding_options_old,
                    pc_lookups.get_meaning(rollover, 'YES_NO')                         rollover,
                    decode(new_hire_contrib, 'PRORATE', 'Prorate', 'No')               new_hire_contrib,
                    to_char(effective_end_date, 'MM/DD/YYYY')                          effective_end_date,
                    to_char(termination_req_date, 'MM/DD/YYYY')                        termination_req_date,
                    pc_lookups.get_meaning(term_eligibility, 'YES_NO')                 term_eligibility,
                    runout_period_days,
                    runout_period_term,
                    grace_period,
                    pc_lookups.get_meaning(transaction_period, 'ACC_PAY_PERIOD')       transaction_period,
                    transaction_limit,
                    pc_lookups.get_meaning(iias_enable, 'IIAS_ENABLE')                 iias_enable,
                    pc_lookups.get_meaning(claim_reimbursed_by, 'CLAIM_REIMBURSED_BY') claim_reimbursed_by,
                    to_char(reimburse_start_date, 'MM/DD/YYYY')                        reimburse_start_date,
                    to_char(reimburse_end_date, 'MM/DD/YYYY')                          reimburse_end_date,
                    pc_lookups.get_meaning(allow_substantiation, 'YES_NO')             allow_substantiation,
                    note
                from
                    ben_plan_enrollment_setup
                where
                        ben_plan_id = (
                            select
                                max(ben_plan_id)
                            from
                                ben_plan_enrollment_setup
                            where
                                    ben_plan_id != l_ben_plan_new(i).ben_plan_id
                                and acc_id = l_ben_plan_new(i).acc_id
                                and plan_type = l_ben_plan_new(i).plan_type
                        )
                    and rownum = 1
            ) loop
                v_old_data := 'Y';
                v_plan_type := ak.plan_type;
                v_ben_plan_name := ak.ben_plan_name;
                v_ben_plan_id_old := ak.ben_plan_id; --- Rprabu 5517 in 16/04/2018
                v_plan_start_date := ak.plan_start_date;
                v_plan_end_date := ak.plan_end_date;
                v_open_enr_start_date := ak.open_enrollment_start_date;
                v_open_enr_end_date := ak.open_enrollment_end_date;
                v_effect_date := ak.effective_date;
                v_status := ak.status;
                v_fiscal_end_date := ak.fiscal_end_date;
                v_takeover := ak.takeover;
                v_orig_eff_date := ak.original_eff_date;
                v_amend_date := ak.amendment_date;
                v_plan_docs_flag := ak.plan_docs_flag;
                v_non_discrm_flag := ak.non_discrm_flag;
                v_min_election := ak.minimum_election;
                v_max_election := ak.maximum_election;
                v_payroll_contrib := ak.payroll_contrib;
                v_funding_options_old := ak.funding_options_old;
                v_rollover := ak.rollover;
                v_new_hire_contrib := ak.new_hire_contrib;
                v_effect_end_date := ak.effective_end_date;
                v_term_req_date := ak.termination_req_date;
                v_term_elig := ak.term_eligibility;
                v_runout_period_days := ak.runout_period_days;
                v_runout_period_term := ak.runout_period_term;
                v_grace_period := ak.grace_period;
                v_tran_period := ak.transaction_period;
                v_tran_limit := ak.transaction_limit;
                v_iias_enable := ak.iias_enable;
                v_claim_reimb_by := ak.claim_reimbursed_by;
                v_reimb_start_date := ak.reimburse_start_date;
                v_reimb_end_date := ak.reimburse_end_date;
                v_allow_subst := ak.allow_substantiation;
                v_note := ak.note;
            end loop;

            for k in (
                select
                    meaning
                from
                    funding_option
                where
                    lookup_code = l_ben_plan_new(i).funding_options
            ) loop
                v_funding_options := k.meaning;
            end loop;

            for k in (
                select
                    meaning
                from
                    fsa_hra_plan_type
                where
                    lookup_code = l_ben_plan_new(i).plan_type
            ) loop
                v_plan_type_new := k.meaning;
            end loop;

            gen_xl_xml.set_column_width(1, 135, v_work_sheet);
           --Plan Setup Work sheet Header
            gen_xl_xml.write_cell_char(1, r, v_work_sheet, 'Employer Name(Account Number)', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_char(1,
                                       r + 1,
                                       v_work_sheet,
                                       pc_entrp.get_entrp_name(l_ben_plan_new(i).entrp_id)
                                       || '('
                                       || pc_entrp.get_acc_num(l_ben_plan_new(i).entrp_id)
                                       || ')',
                                       'BEN_PLAN_COLUMN');

            gen_xl_xml.write_cell_null(1, r + 2, v_work_sheet, 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_null(2, r, v_work_sheet, 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
              --GEN_XL_XML.WRITE_CELL_CHAR( 2,  R+1, V_WORK_SHEET , 'Renewed Plan',  'BEN_PLAN_HEADER_BEN_PLAN1' );
                gen_xl_xml.write_cell_null(2, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            else
                gen_xl_xml.write_cell_char(2, r + 1, v_work_sheet, 'Renewed Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
                gen_xl_xml.write_cell_char(2, r + 2, v_work_sheet, 'Previous Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
            end if;

            gen_xl_xml.write_cell_char(3, r, v_work_sheet, 'Plan Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(3, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(4, r, v_work_sheet, 'Plan Type', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(4, r + 1, v_work_sheet, v_plan_type_new, 'BEN_PLAN_COLUMN');
            else
                if nvl(v_plan_type_new, 0) != nvl(v_plan_type, 0) then
                    gen_xl_xml.write_cell_char(4, r + 1, v_work_sheet, v_plan_type_new, 'BEN_PLAN_COLUMN_CHG');
                    gen_xl_xml.write_cell_char(4, r + 2, v_work_sheet, v_plan_type, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(4, r + 1, v_work_sheet, v_plan_type_new, 'BEN_PLAN_COLUMN');
                    gen_xl_xml.write_cell_char(4, r + 2, v_work_sheet, v_plan_type, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(5, r, v_work_sheet, 'Plan Name', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(5,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).ben_plan_name,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).ben_plan_name,
                       0) != nvl(v_ben_plan_name, 0) then
                    gen_xl_xml.write_cell_char(5,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ben_plan_name,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(5, r + 2, v_work_sheet, v_ben_plan_name, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(5,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ben_plan_name,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(5, r + 2, v_work_sheet, v_ben_plan_name, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(6, r, v_work_sheet, 'Plan Start Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(6,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).plan_start_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).plan_start_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_plan_start_date, 0) then
                    gen_xl_xml.write_cell_char(6,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).plan_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(6, r + 2, v_work_sheet, v_plan_start_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(6,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).plan_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(6, r + 2, v_work_sheet, v_plan_start_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(7, r, v_work_sheet, 'Plan End Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(7,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).plan_end_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).plan_end_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_plan_end_date, 0) then
                    gen_xl_xml.write_cell_char(7,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).plan_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(7, r + 2, v_work_sheet, v_plan_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(7,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).plan_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(7, r + 2, v_work_sheet, v_plan_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(8, r, v_work_sheet, 'Open Enrollment Start Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(8,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).open_enrollment_start_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).open_enrollment_start_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_open_enr_start_date, 0) then
                    gen_xl_xml.write_cell_char(8,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).open_enrollment_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(8, r + 2, v_work_sheet, v_open_enr_start_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(8,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).open_enrollment_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(8, r + 2, v_work_sheet, v_open_enr_start_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(9, r, v_work_sheet, 'Open Enrollment End Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(9,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).open_enrollment_end_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).open_enrollment_end_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_open_enr_end_date, 0) then
                    gen_xl_xml.write_cell_char(9,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).open_enrollment_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(9, r + 2, v_work_sheet, v_open_enr_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(9,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).open_enrollment_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(9, r + 2, v_work_sheet, v_open_enr_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(10, r, v_work_sheet, 'Effective Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(10,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).effective_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).effective_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_effect_date, 0) then
                    gen_xl_xml.write_cell_char(10,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).effective_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(10, r + 2, v_work_sheet, v_effect_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(10,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).effective_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(10, r + 2, v_work_sheet, v_effect_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(11, r, v_work_sheet, 'Plan Status', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(11,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).status,
                                                                  'BEN_PLAN_STATUS'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).status,
                                           'BEN_PLAN_STATUS'),
                    0
                ) != nvl(v_status, 0) then
                    gen_xl_xml.write_cell_char(11,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).status,
                                                                      'BEN_PLAN_STATUS'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(11, r + 2, v_work_sheet, v_status, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(11,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).status,
                                                                      'BEN_PLAN_STATUS'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(11, r + 2, v_work_sheet, v_status, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(12, r, v_work_sheet, 'Fiscal Year End Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(12,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).fiscal_end_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).fiscal_end_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_fiscal_end_date, 0) then
                    gen_xl_xml.write_cell_char(12,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).fiscal_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(12, r + 2, v_work_sheet, v_fiscal_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(12,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).fiscal_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(12, r + 2, v_work_sheet, v_fiscal_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(13, r, v_work_sheet, 'Take Over/Reinstate Prev Plan', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(13,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).takeover,
                                                                  'YES_NO'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).takeover,
                                           'YES_NO'),
                    0
                ) != nvl(v_takeover, 0) then
                    gen_xl_xml.write_cell_char(13,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).takeover,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(13, r + 2, v_work_sheet, v_takeover, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(13,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).takeover,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(13, r + 2, v_work_sheet, v_takeover, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(14, r, v_work_sheet, 'Original Effective Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(14,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).original_eff_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).original_eff_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_orig_eff_date, 0) then
                    gen_xl_xml.write_cell_char(14,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).original_eff_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(14, r + 2, v_work_sheet, v_orig_eff_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(14,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).original_eff_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(14, r + 2, v_work_sheet, v_orig_eff_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(15, r, v_work_sheet, 'Amendment Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(15,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).amendment_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).amendment_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_amend_date, 0) then
                    gen_xl_xml.write_cell_char(15,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).amendment_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(15, r + 2, v_work_sheet, v_amend_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(15,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).amendment_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(15, r + 2, v_work_sheet, v_amend_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(16, r, v_work_sheet, 'Plan Doc ONLY', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(16,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).plan_docs_flag,
                                                                  'YES_NO'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).plan_docs_flag,
                                           'YES_NO'),
                    0
                ) != nvl(v_plan_docs_flag, 0) then
                    gen_xl_xml.write_cell_char(16,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).plan_docs_flag,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(16, r + 2, v_work_sheet, v_plan_docs_flag, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(16,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).plan_docs_flag,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(16, r + 2, v_work_sheet, v_plan_docs_flag, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(17, r, v_work_sheet, 'Non Discrim Testing', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(17,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).non_discrm_flag,
                                                                  'YES_NO'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).non_discrm_flag,
                                           'YES_NO'),
                    0
                ) != nvl(v_non_discrm_flag, 0) then
                    gen_xl_xml.write_cell_char(17,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).non_discrm_flag,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(17, r + 2, v_work_sheet, v_non_discrm_flag, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(17,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).non_discrm_flag,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(17, r + 2, v_work_sheet, v_non_discrm_flag, 'BEN_PLAN_COLUMN');
                end if;
            end if;
           --Annual Election :PAYROLL Setup Work sheet Header
            gen_xl_xml.write_cell_char(18, r, v_work_sheet, 'Annual Election :PAYROLL Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(18, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(19, r, v_work_sheet, 'Min Annual Election', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(19,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).minimum_election,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).minimum_election,
                       -1) != nvl(v_min_election, -1) then
                    gen_xl_xml.write_cell_num(19,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).minimum_election,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(19, r + 2, v_work_sheet, v_min_election, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(19,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).minimum_election,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(19, r + 2, v_work_sheet, v_min_election, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(20, r, v_work_sheet, 'Max Annual Election', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(20,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).maximum_election,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).maximum_election,
                       -1) != nvl(v_max_election, -1) then
                    gen_xl_xml.write_cell_num(20,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).maximum_election,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(20, r + 2, v_work_sheet, v_max_election, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(20,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).maximum_election,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(20, r + 2, v_work_sheet, v_max_election, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(21, r, v_work_sheet, 'Payroll Contribution', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(21,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).payroll_contrib,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).payroll_contrib,
                       -1) != nvl(v_payroll_contrib, -1) then
                    gen_xl_xml.write_cell_num(21,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).payroll_contrib,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(21, r + 2, v_work_sheet, v_payroll_contrib, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(21,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).payroll_contrib,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(21, r + 2, v_work_sheet, v_payroll_contrib, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(22, r, v_work_sheet, 'Funding Options', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(22, r + 1, v_work_sheet, v_funding_options, 'BEN_PLAN_COLUMN');
            else
                if nvl(v_funding_options, 0) != nvl(v_funding_options_old, 0) then
                    gen_xl_xml.write_cell_char(22, r + 1, v_work_sheet, v_funding_options, 'BEN_PLAN_COLUMN_CHG');
                    gen_xl_xml.write_cell_char(22, r + 2, v_work_sheet, v_funding_options_old, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(22, r + 1, v_work_sheet, v_funding_options, 'BEN_PLAN_COLUMN');
                    gen_xl_xml.write_cell_char(22, r + 2, v_work_sheet, v_funding_options_old, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(23, r, v_work_sheet, 'Rollover', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(23,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).rollover,
                                                                  'YES_NO'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).rollover,
                                           'YES_NO'),
                    0
                ) != nvl(v_rollover, 0) then
                    gen_xl_xml.write_cell_char(23,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).rollover,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(23, r + 2, v_work_sheet, v_rollover, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(23,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).rollover,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(23, r + 2, v_work_sheet, v_rollover, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(24, r, v_work_sheet, 'New Hire Contribution', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(24,
                                           r + 1,
                                           v_work_sheet,
                                           case
                                        when l_ben_plan_new(i).new_hire_contrib = 'PRORATE' then
                                            'Prorate'
                                        else 'No'
                                    end,
                                           'BEN_PLAN_COLUMN');
            else
                if case
                    when l_ben_plan_new(i).new_hire_contrib = 'PRORATE' then
                        'Prorate'
                    else 'No'
                end != nvl(v_new_hire_contrib, 'No') then
                    gen_xl_xml.write_cell_char(24,
                                               r + 1,
                                               v_work_sheet,
                                               case
                                            when l_ben_plan_new(i).new_hire_contrib = 'PRORATE' then
                                                'Prorate'
                                            else 'No'
                                        end,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(24, r + 2, v_work_sheet, v_new_hire_contrib, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(24,
                                               r + 1,
                                               v_work_sheet,
                                               case
                                            when l_ben_plan_new(i).new_hire_contrib = 'PRORATE' then
                                                'Prorate'
                                            else 'No'
                                        end,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(24, r + 2, v_work_sheet, v_new_hire_contrib, 'BEN_PLAN_COLUMN');
                end if;
            end if;

           --Termination Setup Work sheet Header
            gen_xl_xml.write_cell_char(25, r, v_work_sheet, 'Termination Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(25, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(26, r, v_work_sheet, 'Termination Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(26,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).effective_end_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).effective_end_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_effect_end_date, 0) then
                    gen_xl_xml.write_cell_char(26,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).effective_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(26, r + 2, v_work_sheet, v_effect_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(26,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).effective_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(26, r + 2, v_work_sheet, v_effect_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(27, r, v_work_sheet, 'Termination Request Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(27,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).termination_req_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).termination_req_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_term_req_date, 0) then
                    gen_xl_xml.write_cell_char(27,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).termination_req_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(27, r + 2, v_work_sheet, v_term_req_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(27,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).termination_req_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(27, r + 2, v_work_sheet, v_term_req_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(28, r, v_work_sheet, 'Term Eligibility', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(28,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).term_eligibility,
                                                                  'YES_NO'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).term_eligibility,
                                           'YES_NO'),
                    0
                ) != nvl(v_term_elig, 0) then
                    gen_xl_xml.write_cell_char(28,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).term_eligibility,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(28, r + 2, v_work_sheet, v_term_elig, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(28,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).term_eligibility,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(28, r + 2, v_work_sheet, v_term_elig, 'BEN_PLAN_COLUMN');
                end if;
            end if;

           --Grace :RUNOUT Setup Header
            gen_xl_xml.write_cell_char(29, r, v_work_sheet, 'Grace :RUNOUT Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(29, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(30, r, v_work_sheet, 'Runout Period Days', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(30,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).runout_period_days,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).runout_period_days,
                       -1) != nvl(v_runout_period_days, -1) then
                    gen_xl_xml.write_cell_num(30,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).runout_period_days,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(30, r + 2, v_work_sheet, v_runout_period_days, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(30,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).runout_period_days,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(30, r + 2, v_work_sheet, v_runout_period_days, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(31, r, v_work_sheet, 'Runout Period Term', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(31,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).runout_period_term,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).runout_period_term,
                       0) != nvl(v_runout_period_term, 0) then
                    gen_xl_xml.write_cell_char(31,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).runout_period_term,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(31, r + 2, v_work_sheet, v_runout_period_term, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(31,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).runout_period_term,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(31, r + 2, v_work_sheet, v_runout_period_term, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(32, r, v_work_sheet, 'Grace Period', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(32,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).grace_period,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).grace_period,
                       -1) != nvl(v_grace_period, -1) then
                    gen_xl_xml.write_cell_num(32,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).grace_period,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(32, r + 2, v_work_sheet, v_grace_period, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(32,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).grace_period,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(32, r + 2, v_work_sheet, v_grace_period, 'BEN_PLAN_COLUMN');
                end if;
            end if;

           --Reimbursement Setup Header
            gen_xl_xml.write_cell_char(33, r, v_work_sheet, 'Reimbursement Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(33, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(34, r, v_work_sheet, 'Transaction Period', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(34,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).transaction_period,
                                                                  'ACC_PAY_PERIOD'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).transaction_period,
                                           'ACC_PAY_PERIOD'),
                    0
                ) != nvl(v_tran_period, 0) then
                    gen_xl_xml.write_cell_char(34,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).transaction_period,
                                                                      'ACC_PAY_PERIOD'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(34, r + 2, v_work_sheet, v_tran_period, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(34,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).transaction_period,
                                                                      'ACC_PAY_PERIOD'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(34, r + 2, v_work_sheet, v_tran_period, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(35, r, v_work_sheet, 'Transaction Limit', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(35,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).transaction_limit,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).transaction_limit,
                       0) != nvl(v_tran_limit, 0) then
                    gen_xl_xml.write_cell_char(35,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).transaction_limit,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(35, r + 2, v_work_sheet, v_tran_limit, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(35,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).transaction_limit,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(35, r + 2, v_work_sheet, v_tran_limit, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(36, r, v_work_sheet, 'IIAS Enable', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(36,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).iias_enable,
                                                                  'IIAS_ENABLE'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).iias_enable,
                                           'IIAS_ENABLE'),
                    0
                ) != nvl(v_iias_enable, 0) then
                    gen_xl_xml.write_cell_char(36,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).iias_enable,
                                                                      'IIAS_ENABLE'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(36, r + 2, v_work_sheet, v_iias_enable, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(36,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).iias_enable,
                                                                      'IIAS_ENABLE'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(36, r + 2, v_work_sheet, v_iias_enable, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(37, r, v_work_sheet, 'Claim Reimbursed By', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(37,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).claim_reimbursed_by,
                                                                  'CLAIM_REIMBURSED_BY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).claim_reimbursed_by,
                                           'CLAIM_REIMBURSED_BY'),
                    0
                ) != nvl(v_claim_reimb_by, 0) then
                    gen_xl_xml.write_cell_char(37,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).claim_reimbursed_by,
                                                                      'CLAIM_REIMBURSED_BY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(37, r + 2, v_work_sheet, v_claim_reimb_by, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(37,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).claim_reimbursed_by,
                                                                      'CLAIM_REIMBURSED_BY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(37, r + 2, v_work_sheet, v_claim_reimb_by, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(38, r, v_work_sheet, 'Reimburse Start Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(38,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).reimburse_start_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).reimburse_start_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_reimb_start_date, 0) then
                    gen_xl_xml.write_cell_char(38,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).reimburse_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(38, r + 2, v_work_sheet, v_reimb_start_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(38,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).reimburse_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(38, r + 2, v_work_sheet, v_reimb_start_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(39, r, v_work_sheet, 'Reimburse End Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(39,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).reimburse_end_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).reimburse_end_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_reimb_end_date, 0) then
                    gen_xl_xml.write_cell_char(39,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).reimburse_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(39, r + 2, v_work_sheet, v_reimb_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(39,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).reimburse_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(39, r + 2, v_work_sheet, v_reimb_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(40, r, v_work_sheet, 'Allow Substantiation', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(40,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).allow_substantiation,
                                                                  'YES_NO'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).allow_substantiation,
                                           'YES_NO'),
                    0
                ) != nvl(v_allow_subst, 0) then
                    gen_xl_xml.write_cell_char(40,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).allow_substantiation,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(40, r + 2, v_work_sheet, v_allow_subst, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(40,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).allow_substantiation,
                                                                      'YES_NO'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(40, r + 2, v_work_sheet, v_allow_subst, 'BEN_PLAN_COLUMN');
                end if;
            end if;

           --- rprabu for 5517 on 16/04/2018
            l_line_no := 41;
            begin
                select
                    coverage_type,
                    annual_election
                bulk collect
                into l_coverage_code
                from
                    ben_plan_coverages
                where
                    ben_plan_id = l_ben_plan_new(i).ben_plan_id
                order by
                    coverage_type;

            end;

            begin
                select
                    coverage_type,
                    annual_election
                bulk collect
                into l_coverage_code_old
                from
                    ben_plan_coverages
                where
                    ben_plan_id = v_ben_plan_id_old
                order by
                    coverage_type;

            end;

            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Coverage Tier', 'BEN_PLAN_HEADER_BEN_PLAN');
            l_line_no := l_line_no + 1;
               -- dbms_output.put_line('Ben PLAN ID'||L_BEN_PLAN_NEW(I).ben_plan_id);

            for x in 1..l_coverage_code.count loop
                gen_xl_xml.write_cell_char(l_line_no,
                                           r,
                                           v_work_sheet,
                                           l_coverage_code(x).coverage_type,
                                           'BEN_PLAN_HEADER');

                if v_old_data = 'N' then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_coverage_code_old(x).deductible,
                                               'BEN_PLAN_COLUMN');

                else
                    if nvl(l_coverage_code_old(x).coverage_type,
                           0) != nvl(l_coverage_code(x).coverage_type,
                                     0) then
                        gen_xl_xml.write_cell_char(l_line_no,
                                                   r + 1,
                                                   v_work_sheet,
                                                   l_coverage_code(x).deductible,
                                                   'BEN_PLAN_COLUMN_CHG');

                        gen_xl_xml.write_cell_char(l_line_no,
                                                   r + 2,
                                                   v_work_sheet,
                                                   l_coverage_code_old(x).deductible,
                                                   'BEN_PLAN_COLUMN_CHG');

                    else
                        gen_xl_xml.write_cell_char(l_line_no,
                                                   r + 1,
                                                   v_work_sheet,
                                                   l_coverage_code(x).deductible,
                                                   'BEN_PLAN_COLUMN');

                        gen_xl_xml.write_cell_char(l_line_no,
                                                   r + 2,
                                                   v_work_sheet,
                                                   l_coverage_code_old(x).deductible,
                                                   'BEN_PLAN_COLUMN');

                    end if;
                end if;

                l_line_no := l_line_no + 1;
            end loop;
                            --- rprabu, code end  for 5517 on 16/04/2018
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Note', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).note,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).note,
                       0) != nvl(v_note, 0) then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).note,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_note, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).note,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_note, 'BEN_PLAN_COLUMN');
                end if;
            end if;

        end loop;

        if l_ben_plan_new.count > 0 then
            gen_xl_xml.close_file;
        end if;
        if file_exists(v_file_name, 'MAILER_DIR') = 'TRUE' then
            v_email := 'IT-team@sterlingadministration.com';
            v_html_msg := '<html><body><br>
                  <p>Daily HRA Renewal Changes Report for the Date '
                          || to_char(sysdate, 'MM/DD/YYYY')
                          || ' </p> <br> <br>
                   </body></html>';
            if user = 'SAM' then
                v_email := 'clientservices@sterlingadministration.com,Renewals@sterlingadministration.com'
                           || ',dan.tidball@sterlingadministration.com,DL_Sales@sterlingadministration.com'
                           || ',sarah.soman@sterlingadministration.com,IT-Team@sterlingadministration.com'
                           || ',VHSTeam@sterlingadministration.com';
            else
                v_email := 'IT-team@sterlingadministration.com';
            end if;

            if p_acc_id is null then

              /*After upgrade oracle@sterlingadministration.com does not work */
                mail_utility.send_file_in_emails(
                    p_from_email   => 'oracle@sterlinghsa.com',
                    p_to_email     => v_email,
                    p_file_name    => v_file_name,
                    p_sql          => null,
                    p_html_message => v_html_msg,
                    p_report_title => 'Daily HRA Renewal Changes Report for the Date ' || to_char(sysdate, 'MM/DD/YYYY')
                );
            end if;

            if p_acc_id is not null then
                pc_crm_interface.export_changes_report(p_acc_id, v_file_name);
            end if;
        end if;

    exception
        when no_data_found then
            dbms_output.put_line('ERROR '
                                 || ' '
                                 || sqlerrm
                                 || ' '
                                 || sqlcode);
        when others then
            dbms_output.put_line('ERROR '
                                 || ' '
                                 || sqlerrm
                                 || ' '
                                 || sqlcode);
    end pos_renewal_det_hra;

    procedure pos_renewal_det_erisa (
        p_acc_id in number default null
    ) is

        type rec_ben_erisa is
            table of erisa_rec;
        type rec_worksheet is record (
            work_book varchar2(4000)
        );
        type tbl_worksheet is
            table of rec_worksheet;
        type rec_benefit_code is
            table of benefit_code_rec;
        l_benefit_code_old    rec_benefit_code;
        l_benefit_code_new    rec_benefit_code;
        l_ben_plan_new        rec_ben_erisa;
        l_worksheet           rec_worksheet;
        v_start               varchar2(1) := 'Y';
        v_old_data            varchar2(1);
        v_file_id             number;
        v_work_sheet          varchar2(4000);
        v_file_name           varchar2(4000);
        r                     number := 0;
        v_plan_type           varchar2(100);
        v_ben_plan_name       varchar2(100);
        v_plan_start_date     varchar2(100);
        v_plan_end_date       varchar2(100);
        v_open_enr_start_date varchar2(100);
        v_open_enr_end_date   varchar2(100);
        v_effect_date         varchar2(100);
        v_status              varchar2(100);
        v_no_of_eligible      varchar2(100);
        v_entity_type         varchar2(100);
        v_affiliated_er       varchar2(100);
        v_controlled_group    varchar2(100);
        v_ben_plan_number     varchar2(100);
        v_plan_include        varchar2(100);
        v_clm_lang_in_spd     varchar2(100);
        v_grandfathered       varchar2(100);
        v_form55_opted        varchar2(100);
        v_broker_added        varchar2(100);
        v_ga_added            varchar2(100);
        v_html_msg            varchar2(4000);
        v_broker_contact      varchar2(4000);
        v_ga_contact          varchar2(4000);
        v_email               varchar2(4000);
        v_address_change      number := 0;
        v_ben_code_change     number := 0;
        v_special_instruction number := 0;
        l_line_no             number := 0;
        l_description         varchar2(100);
        l_eligibility         varchar2(100);
        l_er_cont_pref        number;
        l_ee_cont_pref        number;
    begin
        dbms_output.put_line('START ERISA CHANGE');
        select
            *
        bulk collect
        into l_ben_plan_new
        from
            (
                select
                    es.entrp_id,
                    bp.ben_plan_id,
                    bp.acc_id,
                    pc_lookups.get_meaning(bp.plan_type, 'PLAN_TYPE_WRAP')    plan_type,
                    b.acc_num,
                    bp.ben_plan_name,
                    to_char(bp.plan_start_date, 'MM/DD/YYYY')                 plan_start_date,
                    to_char(bp.plan_end_date, 'MM/DD/YYYY')                   plan_end_date,
                    to_char(bp.effective_date, 'MM/DD/YYYY')                  effective_date,
                    pc_lookups.get_meaning(bp.status, 'BEN_PLAN_STATUS')      status,
                    es.no_of_eligible,
                    pc_lookups.get_meaning(es.entity_type, 'ENTITY_TYPE')     entity_type,
                    pc_lookups.get_meaning(es.old_entity_type, 'ENTITY_TYPE') old_entity_type,
                    pc_lookups.get_meaning(es.affiliated_er, 'YES_NO')        affiliated_er,
                    pc_lookups.get_meaning(es.controlled_group, 'YES_NO')     controlled_group,
                    bp.ben_plan_number,
                    es.plan_include,
                    pc_lookups.get_meaning(es.clm_lang_in_spd, 'YES_NO')      clm_lang_in_spd,
                    pc_lookups.get_meaning(es.grandfathered, 'YES_NO')        grandfathered,
                    pc_lookups.get_meaning(es.form55_opted, 'YES_NO')         form55_opted,
                    pc_broker.get_broker_name(b.broker_id)                    broker_added,
                    pc_sales_team.get_general_agent_name(b.ga_id)             ga_added,
                    bpr.ben_plan_id                                           old_plan_id
                from
                    online_renewals           es,
                    enterprise                a,
                    account                   b,
                    ben_plan_enrollment_setup bp,
                    ben_plan_renewals         bpr
                where
                        b.acc_id = nvl(p_acc_id, b.acc_id)
                    and es.entrp_id = a.entrp_id
                    and a.entrp_id = b.entrp_id
                    and es.ben_plan_id = bp.ben_plan_id
                    and es.ben_plan_id = bpr.renewed_plan_id
                 -- AND b.acc_num = 'GERW052569'
                    and trunc(es.creation_date) >= trunc(sysdate) - 1
            );

        dbms_output.put_line('BEFORE LOOP');
        for i in 1..l_ben_plan_new.count loop
            if v_start = 'Y' then
                dbms_output.put_line('EXCEL SETUP');
                l_line_no := 0;
                v_file_id := pc_file_upload.insert_file_seq('DAILY_RENEWAL_BEN_PLAN_ERISA');
                v_file_name := 'Erisa_Renewal_Changes_Report_'
                               || v_file_id
                               || '_'
                               || to_char(sysdate, 'YYYYMMDDHH24MISS')
                               || '.xls';

              --GEN_XL_XML.CREATE_EXCEL( 'DAILY_RENEWAL_POP_ERISA',V_FILE_NAME) ;
                gen_xl_xml.create_excel('MAILER_DIR', v_file_name);
                gen_xl_xml.create_style('BEN_PLAN_HEADER', 'Calibri', 'Black', 10,
                                        p_bold => true);
                gen_xl_xml.create_style('BEN_PLAN_HEADER_BEN_PLAN', 'Calibri', 'Red', 10,
                                        p_bold => true);
                gen_xl_xml.create_style('BEN_PLAN_HEADER_BEN_PLAN1', 'Calibri', 'Blue', 10,
                                        p_bold => true);
                gen_xl_xml.create_style('BEN_PLAN_COLUMN', 'Calibri', 'Black', 9);
                gen_xl_xml.create_style('BEN_PLAN_COLUMN_CHG', 'Calibri', 'Green', 9,
                                        p_backcolor => 'Yellow');
                for ik in 1..l_ben_plan_new.count loop
                    l_worksheet.work_book := l_ben_plan_new(ik).acc_num
                                             || '-'
                                             || l_ben_plan_new(ik).plan_type;

                    gen_xl_xml.create_worksheet(l_worksheet.work_book);
                    v_work_sheet := l_worksheet.work_book;
                end loop;

            end if;

            dbms_output.put_line('VARIABLE SETUP');
            v_old_data := 'N';
            v_start := 'N';
            r := 1;
            v_work_sheet := l_ben_plan_new(i).acc_num
                            || '-'
                            || l_ben_plan_new(i).plan_type;

            v_plan_type := null;
            v_ben_plan_name := null;
            v_plan_start_date := null;
            v_plan_end_date := null;
            v_open_enr_start_date := null;
            v_open_enr_end_date := null;
            v_effect_date := null;
            v_status := null;
            v_no_of_eligible := null;
            v_entity_type := l_ben_plan_new(i).old_entity_type;
            v_affiliated_er := null;
            v_controlled_group := null;
            v_ben_plan_number := null;
            v_plan_include := null;
            v_clm_lang_in_spd := null;
            v_grandfathered := null;
            v_form55_opted := null;
            v_broker_added := null;
            v_ga_added := null;
            v_broker_contact := null;
            v_ga_contact := null;
            v_address_change := 0;
            v_ben_code_change := 0;
            v_special_instruction := 0;
            for j in (
                select
                    agency_name
                from
                    external_sales_team_leads
                where
                        entity_type = 'BROKER'
                    and entrp_id = l_ben_plan_new(i).entrp_id
                    and ref_entity_id = l_ben_plan_new(i).ben_plan_id
                    and ref_entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
            ) loop
                l_ben_plan_new(i).broker_added := j.agency_name;
            end loop;

            for j in (
                select
                    agency_name
                from
                    external_sales_team_leads
                where
                        entity_type = 'GA'
                    and entrp_id = l_ben_plan_new(i).entrp_id
                    and ref_entity_id = l_ben_plan_new(i).ben_plan_id
                    and ref_entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
            ) loop
                l_ben_plan_new(i).ga_added := j.agency_name;
            end loop;

            pc_log.log_error('Old Ben ID..',
                             l_ben_plan_new(i).old_ben_plan_id);
            for ak in (
                select
                    pc_lookups.get_meaning(bp.plan_type, 'PLAN_TYPE_WRAP') plan_type,
                    b.acc_num,
                    bp.ben_plan_name,
                    to_char(bp.plan_start_date, 'MM/DD/YYYY')              plan_start_date,
                    to_char(bp.plan_end_date, 'MM/DD/YYYY')                plan_end_date,
                    to_char(bp.effective_date, 'MM/DD/YYYY')               effective_date,
                    pc_lookups.get_meaning(bp.status, 'BEN_PLAN_STATUS')   status,
                    bp.ben_plan_number,
                    pc_lookups.get_meaning(a.entity_type, 'ENTITY_TYPE')   entity_type,
                    pc_lookups.get_meaning(bp.clm_lang_in_spd, 'YES_NO')   clm_lang_in_spd,
                    pc_lookups.get_meaning(bp.grandfathered, 'YES_NO')     grandfathered,
                    pc_lookups.get_meaning(bp.is_5500, 'YES_NO')           form55_opted,
                    pc_broker.get_broker_name(b.broker_id)                 broker_added ---NVL(PC_BROKER.GET_BROKER_NAME(B.BROKER_ID),'No') BROKER_ADDED
                    ,
                    pc_sales_team.get_general_agent_name(b.ga_id)          ga_added --NVL(PC_SALES_TEAM.GET_GENERAL_AGENT_NAME(B.GA_ID),'No') GA_ADDED
                from
                    enterprise                a,
                    account                   b,
                    ben_plan_enrollment_setup bp
                where
                        a.entrp_id = b.entrp_id
                    and b.acc_id = bp.acc_id
                    and bp.ben_plan_id = l_ben_plan_new(i).old_ben_plan_id
            ) loop
                                                  --AND BEN_PLAN_NUMBER = L_BEN_PLAN_NEW(I).BEN_PLAN_NUMBER)) LOOP
                v_old_data := 'Y';
                v_plan_type := ak.plan_type;
                v_ben_plan_name := ak.ben_plan_name;
                v_plan_start_date := ak.plan_start_date;
                v_plan_end_date := ak.plan_end_date;
                v_effect_date := ak.effective_date;
                v_status := ak.status;
            --    V_ENTITY_TYPE          :=  AK.ENTITY_TYPE;
                v_clm_lang_in_spd := ak.clm_lang_in_spd;
                v_grandfathered := ak.grandfathered;
                v_form55_opted := ak.form55_opted;
                v_broker_added := ak.broker_added;
                v_ga_added := ak.ga_added;
                v_ben_plan_number := ak.ben_plan_number;
                for xx in (
                    select
                        no_of_eligible_old,
                        pc_lookups.get_meaning(
                            nvl(affiliated_er_old, 'N'),
                            'YES_NO'
                        ) affiliated_er_old,
                        pc_lookups.get_meaning(
                            nvl(controlled_group_old, 'N'),
                            'YES_NO'
                        ) controlled_group_old,
                        plan_include_old
                    from
                        online_renewals
                    where
                        ben_plan_id = l_ben_plan_new(i).ben_plan_id
                ) loop
                    v_no_of_eligible := xx.no_of_eligible_old;
                    v_affiliated_er := xx.affiliated_er_old;
                    v_controlled_group := xx.controlled_group_old;
                    v_plan_include := xx.plan_include_old;
                end loop;

            end loop;

            dbms_output.put_line('INNER FOR LOOP END');
            for j in (
                select -- WM_CONCAT(FIRST_NAME) FIRST_NAME  -- Wm_Concat function replaced by listagg by RPRABU on 17/10/2017
                    listagg(first_name, ',') within group(
                    order by
                        first_name
                    ) first_name
                from
                    (
                        select distinct
                            first_name first_name
                        from
                            contact_leads
                        where
                                contact_type = 'BROKER'
                            and ref_entity_id = l_ben_plan_new(i).ben_plan_id
                            and ref_entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                    )
            ) loop
                v_broker_contact := j.first_name;
            end loop;

            for j in (
                select --WM_CONCAT(FIRST_NAME) FIRST_NAME FROM
                    listagg(first_name, ',') within group(
                    order by
                        first_name
                    ) first_name
                from
                    (
                        select distinct
                            first_name first_name
                        from
                            contact_leads
                        where
                                contact_type = 'GA'
                            and ref_entity_id = l_ben_plan_new(i).ben_plan_id
                            and ref_entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                    )
            ) loop
                v_ga_contact := j.first_name;
            end loop;

            l_line_no := 0;
            gen_xl_xml.set_column_width(1, 150, v_work_sheet);
           --Plan Setup Work sheet Header
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Employer Name(Account Number)', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_char(l_line_no,
                                       r + 1,
                                       v_work_sheet,
                                       pc_entrp.get_entrp_name(l_ben_plan_new(i).entrp_id)
                                       || '('
                                       || l_ben_plan_new(i).acc_num
                                       || ')',
                                       'BEN_PLAN_COLUMN');

            gen_xl_xml.write_cell_null(l_line_no, r + 2, v_work_sheet, 'BEN_PLAN_HEADER');
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_null(l_line_no, r, v_work_sheet, 'BEN_PLAN_HEADER');
            dbms_output.put_line('1');
            if v_old_data = 'N' then
              --GEN_XL_XML.WRITE_CELL_CHAR( 2,  R+1, V_WORK_SHEET , 'Renewed Plan',  'BEN_PLAN_HEADER_BEN_PLAN1' );
                gen_xl_xml.write_cell_null(l_line_no, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            else
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, 'Renewed Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
                gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, 'Previous Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
            end if;

            dbms_output.put_line('2');
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(l_line_no, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Type', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).plan_type,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).plan_type,
                       'S') != nvl(v_plan_type, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_type,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_type, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_type,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_type, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('3');
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Name', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).ben_plan_name,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).ben_plan_name,
                       'S') != nvl(v_ben_plan_name, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ben_plan_name,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_ben_plan_name, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ben_plan_name,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_ben_plan_name, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('4');
            select
                count(*)
            into v_address_change
            from
                notes
            where
                    entity_id = l_ben_plan_new(i).entrp_id
                and entity_type = 'ENTERPRISE'
                and note_action = 'ADDRESS_CHANGE'
                and creation_date > trunc(sysdate) - 1;

            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Company Address', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet,
                                       case
                                           when v_address_change > 0 then
                                               'Yes'
                                           else 'No'
                                       end, 'BEN_PLAN_COLUMN');

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Start Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).plan_start_date,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).plan_start_date,
                       'S') != nvl(v_plan_start_date, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_start_date,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_start_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_start_date,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_start_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan End Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).plan_end_date,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).plan_end_date,
                       'S') != nvl(v_plan_end_date, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_end_date,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_end_date,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('5');
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Effective Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).effective_date,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).effective_date,
                       'S') != nvl(v_effect_date, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).effective_date,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_effect_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).effective_date,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_effect_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Status', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).status,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).status,
                       'S') != nvl(v_status, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).status,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_status, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).status,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_status, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('6');
            pc_log.log_error('Before New..', 'Writing Data3');
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'No of eligible employees', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(l_line_no,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).no_of_eligible,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).no_of_eligible,
                       -1) != nvl(v_no_of_eligible, -1) then
                    gen_xl_xml.write_cell_num(l_line_no,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).no_of_eligible,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(l_line_no, r + 2, v_work_sheet, v_no_of_eligible, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(l_line_no,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).no_of_eligible,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(l_line_no, r + 2, v_work_sheet, v_no_of_eligible, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Type of Entity', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).entity_type,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).entity_type,
                       'S') != nvl(v_entity_type, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).entity_type,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_entity_type, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).entity_type,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_entity_type, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Affilitated Employers', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).affiliated_er,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).affiliated_er,
                       'S') != nvl(v_affiliated_er, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).affiliated_er,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_affiliated_er, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).affiliated_er,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_affiliated_er, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('7');
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Company Owned by another company', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).controlled_group,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).controlled_group,
                       'S') != nvl(v_controlled_group, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).controlled_group,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_controlled_group, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).controlled_group,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_controlled_group, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Health :WELFARE Plan Number', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(l_line_no,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).ben_plan_number,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).ben_plan_number,
                       -1) != nvl(v_ben_plan_number, -1) then
                    gen_xl_xml.write_cell_num(l_line_no,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).ben_plan_number,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(l_line_no, r + 2, v_work_sheet, v_ben_plan_number, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(l_line_no,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).ben_plan_number,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(l_line_no, r + 2, v_work_sheet, v_ben_plan_number, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('8');
            select
                count(*)
            into v_ben_code_change
            from
                benefit_codes
            where
                    entity_id = l_ben_plan_new(i).ben_plan_id
                and entity_type = 'SUBSIDIARY_CONTRACT';

            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Welfare benefit plan Appendix', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet,
                                       case
                                           when v_ben_code_change > 0 then
                                               'Yes'
                                           else 'No'
                                       end, 'BEN_PLAN_COLUMN');

            dbms_output.put_line('9');
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'The Wrap plan will include', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).plan_include,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).plan_include,
                       'S') != nvl(v_plan_include, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_include,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_include, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_include,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_include, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Claims language included', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).clm_lang_in_spd,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).clm_lang_in_spd,
                       'S') != nvl(v_clm_lang_in_spd, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).clm_lang_in_spd,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_clm_lang_in_spd, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).clm_lang_in_spd,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_clm_lang_in_spd, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Grandfather status', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).grandfathered,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).grandfathered,
                       'S') != nvl(v_grandfathered, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).grandfathered,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_grandfathered, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).grandfathered,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_grandfathered, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('10');
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Sterling file Form 5500', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).form55_opted,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).form55_opted,
                       'S') != nvl(v_form55_opted, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).form55_opted,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_form55_opted, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).form55_opted,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_form55_opted, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1; ---Added by Puja

            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Broker Added ?', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).broker_added,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).broker_added,
                       'S') != nvl(v_broker_added, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).broker_added,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_broker_added, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).broker_added,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_broker_added, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            dbms_output.put_line('11');
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'General Agent Added ?', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).ga_added,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).ga_added,
                       'S') != nvl(v_ga_added, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ga_added,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_ga_added, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ga_added,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_ga_added, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('12');
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Broker Contact', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no,
                                       r + 1,
                                       v_work_sheet,
                                       replace(
                                replace(v_broker_contact, '>', ''),
                                '<',
                                ''
                            ),
                                       'BEN_PLAN_COLUMN');

            l_line_no := l_line_no + 1; --Added by Puja
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'GA Contact', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no,
                                       r + 1,
                                       v_work_sheet,
                                       replace(
                                replace(v_ga_contact, '>', ''),
                                '<',
                                ''
                            ),
                                       'BEN_PLAN_COLUMN');

            dbms_output.put_line('13');
            dbms_output.put_line('Ben ID OLD' || l_ben_plan_new(i).old_ben_plan_id);
            pc_log.log_error('OLD BEN ID..',
                             l_ben_plan_new(i).old_ben_plan_id);
            pc_log.log_error('NEWBEN ID..',
                             l_ben_plan_new(i).ben_plan_id);
            select
                count(*)
            into v_special_instruction
            from
                notes
            where
                    entity_id = l_ben_plan_new(i).ben_plan_id
                and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                and note_action = 'SPECIAL_INSTRUCTIONS'
                and creation_date > trunc(sysdate) - 1;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Special instructions', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet,
                                       case
                                           when v_special_instruction > 0 then
                                               'Yes'
                                           else 'No'
                                       end, 'BEN_PLAN_COLUMN');

                   /*Ticket#5515 */
                  --Fetching welfare chart for renewed plan
            select
                case
                    when a.benefit_code_name = 'OTHER' then
                        lkp.meaning
                        || '-'
                        || a.description
                    else
                        lkp.meaning
                end description,
                eligibility,
                er_cont_pref,
                ee_cont_pref,
                er_ee_contrib_lng,
                refer_to_doc
            bulk collect
            into l_benefit_code_new
            from
                benefit_codes a,
                lookups       lkp
            where
                    entity_id = l_ben_plan_new(i).ben_plan_id
                and a.entity_type = 'SUBSIDIARY_CONTRACT'
                and lkp.lookup_code = a.benefit_code_name
                and lkp.lookup_name in ( 'SUBSIDIARY_CONTRACTS', 'CLAIM_LNG_OPTIONS' );

            l_line_no := l_line_no + 2;
            gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, 'Welfare Chart(Renewed)', 'BEN_PLAN_COLUMN_CHG');
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Welfare Benefit Plan Name', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, 'Eligibility', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, 'ER Contribution', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 3, v_work_sheet, 'EE Contribution', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 4, v_work_sheet, 'Contribution Language option', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 5, v_work_sheet, 'Refer to text', 'BEN_PLAN_HEADER');
            l_line_no := l_line_no + 1;
            for x in 1..l_benefit_code_new.count loop
                gen_xl_xml.write_cell_char(l_line_no,
                                           r,
                                           v_work_sheet,
                                           l_benefit_code_new(x).description,
                                           'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_benefit_code_new(x).eligibility,
                                           'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 2,
                                           v_work_sheet,
                                           l_benefit_code_new(x).er_contrib,
                                           'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 3,
                                           v_work_sheet,
                                           l_benefit_code_new(x).ee_contrib,
                                           'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 4,
                                           v_work_sheet,
                                           l_benefit_code_new(x).er_ee_contrib_lng,
                                           'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 5,
                                           v_work_sheet,
                                           l_benefit_code_new(x).refer_to_doc,
                                           'BEN_PLAN_COLUMN');

                l_line_no := l_line_no + 1;
            end loop;--New plan welfare chart

                 --Fetching welfare chart for old plan
            select
                case
                    when a.benefit_code_name = 'OTHER' then
                        lkp.meaning
                        || '-'
                        || a.description
                    else
                        lkp.meaning
                end description,
                eligibility,
                er_cont_pref,
                ee_cont_pref,
                er_ee_contrib_lng,
                refer_to_doc
            bulk collect
            into l_benefit_code_old
            from
                benefit_codes a,
                lookups       lkp
            where
                    entity_id = l_ben_plan_new(i).old_ben_plan_id
                and lkp.lookup_code = a.benefit_code_name
                and lkp.lookup_name in ( 'SUBSIDIARY_CONTRACTS', 'CLAIM_LNG_OPTIONS' );

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, 'Welfare Chart(Previous)', 'BEN_PLAN_COLUMN_CHG');
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Welfare Benefit Plan Name', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, 'Eligibility', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, 'ER Contribution', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 3, v_work_sheet, 'EE Contribution', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 4, v_work_sheet, 'Contribution Language option', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 5, v_work_sheet, 'Refer to text', 'BEN_PLAN_HEADER');
            l_line_no := l_line_no + 1;
            for x in 1..l_benefit_code_old.count loop
                gen_xl_xml.write_cell_char(l_line_no,
                                           r,
                                           v_work_sheet,
                                           l_benefit_code_old(x).description,
                                           'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_benefit_code_old(x).eligibility,
                                           'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 2,
                                           v_work_sheet,
                                           l_benefit_code_old(x).er_contrib,
                                           'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 3,
                                           v_work_sheet,
                                           l_benefit_code_old(x).ee_contrib,
                                           'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 4,
                                           v_work_sheet,
                                           l_benefit_code_old(x).er_ee_contrib_lng,
                                           'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 5,
                                           v_work_sheet,
                                           l_benefit_code_old(x).refer_to_doc,
                                           'BEN_PLAN_COLUMN');

                l_line_no := l_line_no + 1;
            end loop;--Old plan welfare chart

        end loop;

        if l_ben_plan_new.count > 0 then
            gen_xl_xml.close_file;
        end if;
        dbms_output.put_line('User' || user);
        if file_exists(v_file_name, 'MAILER_DIR') = 'TRUE' then
            v_html_msg := '<html><body><br>
                  <p>Daily Erisa Renewal Changes Report for the Date '
                          || to_char(sysdate, 'MM/DD/YYYY')
                          || ' </p> <br> <br>
                   </body></html>';
            if user = 'SAM' then
                v_email := 'compliance@sterlingadministration.com'
                           || ',dan.tidball@sterlingadministration.com,DL_Sales@sterlingadministration.com'
                           || ',sarah.soman@sterlingadministration.com,IT-Team@sterlingadministration.com'
                           || ',VHSTeam@sterlingadministration.com';
            else
                v_email := 'IT-team@sterlingadministration.com';
                 --V_email :=  'puja.ghosh@sterlingadministration.com';

            end if;

            dbms_output.put_line('User befor Email' || user);

                 /*After upgrade oracle@sterlingadministration.com does not work */
            mail_utility.send_file_in_emails(
                p_from_email   => 'oracle@sterlinghsa.com',
                p_to_email     => v_email,
                p_file_name    => v_file_name,
                p_sql          => null,
                p_html_message => v_html_msg,
                p_report_title => 'Daily Erisa Renewal Changes Report for the Date ' || to_char(sysdate, 'MM/DD/YYYY')
            );

        end if;

        dbms_output.put_line('User After Email' || user);
--Puja commented
        if
            p_acc_id is not null
            and v_file_name is not null
        then
            pc_crm_interface.export_changes_report(p_acc_id, v_file_name);
        end if;

    exception
        when no_data_found then
            dbms_output.put_line('ERROR '
                                 || ' '
                                 || sqlerrm
                                 || ' '
                                 || sqlcode);
        when others then
            dbms_output.put_line('ERROR '
                                 || ' '
                                 || sqlerrm
                                 || ' '
                                 || sqlcode);
    end pos_renewal_det_erisa;

    procedure pos_renewal_det_cobra (
        p_acc_id in number default null
    ) is

        type rec_ben_cobra is
            table of cobra_rec;
        type rec_worksheet is record (
            work_book varchar2(4000)
        );
        type tbl_worksheet is
            table of rec_worksheet;
        l_ben_plan_new         rec_ben_cobra;
        l_worksheet            rec_worksheet;
        v_start                varchar2(1) := 'Y';
        v_old_data             varchar2(1);
        v_file_id              number;
        v_work_sheet           varchar2(4000);
        v_file_name            varchar2(4000);
        r                      number := 0;
        v_plan_type            varchar2(100);
        v_plan_start_date      varchar2(100);
        v_plan_end_date        varchar2(100);
        v_emp_name             varchar2(100);
        v_acc_num              varchar2(100);
        v_broker_name          varchar2(1000);
        v_ga_name              varchar2(1000);
        v_broker_id            number;
        v_ga_id                number;
        v_rep_name             varchar2(100);
        v_no_of_eligible_old   number;
        v_entrp_id             number;
        v_batch_number         number;
        v_html_msg             varchar2(4000);
        v_renewal_fee          number;
        v_carrier_notif        number;
        v_open_enrll_suite     number;
        v_carrier_pay          number;
        v_pay_method           varchar2(100);
        v_renewal_fee_old      number;
        v_carrier_notif_old    number;
        v_open_enrll_suite_old number;
        v_carrier_pay_old      number;
        v_pay_method_old       varchar2(100);
        v_broker_contact       varchar2(4000);
        v_ga_contact           varchar2(4000);
        v_email                varchar2(4000);
        l_old_start_date       date;
        l_old_end_date         date;
           /* Modified for ticket#5520 */
        v_state_old            number;
        v_state_new            number;
    begin
        select
            *
        bulk collect
        into l_ben_plan_new
        from
            (
                select
                    a.name,
                    es.acc_id,
                    b.acc_num,
                    es.broker_id,
                    es.ga_id,
                    pc_broker.get_broker_name(b.broker_id)        broker_name,
                    pc_sales_team.get_general_agent_name(b.ga_id) ga_name,
                    to_char(es.start_date, 'MM/DD/RRRR')          plan_start_date,
                    to_char(es.end_date, 'MM/DD/RRRR')            plan_end_date,
                    pc_account.get_salesrep_name(b.salesrep_id)   rep_name,
                    a.no_of_eligible,
                    a.entrp_id,
                    es.plan_type,
                    es.renewal_batch_number,
                    es.no_of_eligible_old,
                    es.ben_plan_id  --Ticket#4408
                from
                    ben_plan_renewals es,
                    enterprise        a,
                    account           b
                where
                        b.acc_id = nvl(p_acc_id, b.acc_id)
                    and es.acc_id = b.acc_id
                    and a.entrp_id = b.entrp_id
                    and es.plan_type = 'COBRA'
                    and b.account_type = 'COBRA'
                    and trunc(es.creation_date) >= trunc(sysdate) - 30
            );

        for i in 1..l_ben_plan_new.count loop
            if v_start = 'Y' then
                v_file_id := pc_file_upload.insert_file_seq('DAILY_RENEWAL_BEN_PLAN_COBRA');
--                 V_FILE_NAME       := 'Cobra_Renewal_Changes_Report_'||V_FILE_ID||'_'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')||'.xls';
                v_file_name := l_ben_plan_new(i).acc_num
                               || '_Cobra_Renewal_Changes_Report_'
                               || to_char(sysdate, 'YYYYMMDD')
                               || '.xls';   --Added code by sekhar for Ticket #12544

                 --GEN_XL_XML.CREATE_EXCEL( 'DAILY_RENEWAL_POP_ERISA',V_FILE_NAME) ;
                gen_xl_xml.create_excel('MAILER_DIR', v_file_name);
                gen_xl_xml.create_style('BEN_PLAN_HEADER', 'Calibri', 'Black', 10,
                                        p_bold => true);
                gen_xl_xml.create_style('BEN_PLAN_HEADER_BEN_PLAN', 'Calibri', 'Red', 10,
                                        p_bold => true);
                gen_xl_xml.create_style('BEN_PLAN_HEADER_BEN_PLAN1', 'Calibri', 'Blue', 10,
                                        p_bold => true);
                gen_xl_xml.create_style('BEN_PLAN_COLUMN', 'Calibri', 'Black', 9);
                gen_xl_xml.create_style('BEN_PLAN_COLUMN_CHG', 'Calibri', 'Green', 9,
                                        p_backcolor => 'Yellow');

--                 FOR IK IN 1 .. L_BEN_PLAN_NEW.COUNT LOOP
--                     L_WORKSHEET.WORK_BOOK := L_BEN_PLAN_NEW(IK).ACC_NUM||'-'||L_BEN_PLAN_NEW(IK).PLAN_TYPE;
                l_worksheet.work_book := l_ben_plan_new(i).acc_num;    --Added code by sekhar for Ticket #12544
                gen_xl_xml.create_worksheet(l_worksheet.work_book);
                v_work_sheet := l_worksheet.work_book;
--                 END LOOP;
            end if;

            v_old_data := 'N';
--              V_START                := 'N';   --commented code by sekhar for Ticket #12544
            r := 1;
--              V_WORK_SHEET           := L_BEN_PLAN_NEW(I).ACC_NUM||'-'||L_BEN_PLAN_NEW(I).PLAN_TYPE;
            v_work_sheet := l_ben_plan_new(i).acc_num;  --Added code by sekhar for Ticket #12544
            v_emp_name := null;
              /*IF L_BEN_PLAN_NEW(I).ACC_NUM <> V_ACC_NUM THEN
                 V_START  := 'Y';
              END IF;*/
            v_acc_num := null;
            v_broker_id := null;
            v_ga_id := null;
            v_plan_start_date := null;
            v_plan_end_date := null;
            v_rep_name := null;
            v_no_of_eligible_old := null;
            v_entrp_id := null;
            v_plan_type := null;
            v_batch_number := null;
            v_broker_name := null;
            v_ga_name := null;
            v_renewal_fee_old := null;
            v_carrier_notif_old := null;
            v_open_enrll_suite_old := null;
              /*Modified on 23/04/18 for ticket#5520 */
            v_state_old := null;
            v_state_new := null;
            v_carrier_pay_old := null;
            v_pay_method_old := null;
            v_renewal_fee := null;
            v_carrier_notif := null;
            v_open_enrll_suite := null;
            v_carrier_pay := null;
            v_pay_method := null;
              /*IF V_ACC_NUM <> L_BEN_PLAN_NEW(I).ACC_NUM THEN
                 V_START := 'Y';
              END IF;*/
            v_no_of_eligible_old := l_ben_plan_new(i).no_of_eligible_old;
               --Ticket#4408 . Old plan start and End date can niow be derived from ben_plan_enrollment_setup. we need not go to AR INVOICE
            select
                plan_end_date
            into l_old_end_date
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id = l_ben_plan_new(i).ben_plan_id;

            select
                plan_start_date
            into l_old_start_date
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id = l_ben_plan_new(i).ben_plan_id;

            for ak in (
                select
                    rpd.coverage_type,
                    arl.total_line_amount,
                    ar.payment_method,
                    ar.start_date,
                    ar.end_date
                from
                    ar_invoice       ar,
                    ar_invoice_lines arl,
                    rate_plan_detail rpd
                where
                        ar.acc_id = l_ben_plan_new(i).acc_id
                    and ar.rate_plan_id = rpd.rate_plan_id
                    and ar.invoice_id = arl.invoice_id
                    and ar.invoice_id = (
                        select
                            max(ar1.invoice_id)
                        from
                            ar_invoice_lines arl1,
                            ar_invoice       ar1
                        where
                                arl1.rate_code = '30'
                            and arl1.invoice_id = ar1.invoice_id
                            and ar1.acc_id = l_ben_plan_new(i).acc_id
                    )
            ) loop
                v_old_data := 'Y';
                if ak.coverage_type = 'MAIN_COBRA_SERVICE' then
                    v_renewal_fee_old := ak.total_line_amount;
                end if;
                if ak.coverage_type = 'OPTIONAL_COBRA_SERVICE_CN' then
                    v_carrier_notif_old := ak.total_line_amount;
                end if;
                if ak.coverage_type = 'OPEN_ENROLLMENT_SUITE' then
                    v_open_enrll_suite_old := ak.total_line_amount;
                end if;

                  /*Modified on 23/04/18 for ticket#5520 */
                if ak.coverage_type = 'OPTIONAL_COBRA_SERVICE_SC' then
                    v_state_old := ak.total_line_amount;
                end if;
                  /*Modified on 23/04/18 for ticket#5520 */

                v_pay_method_old := pc_lookups.get_meaning(
                    upper(ak.payment_method),
                    'PAYMENT_METHOD'
                );
            end loop;
                       --Ticket#4408
            v_plan_start_date := to_char(l_old_start_date, 'MM/DD/RRRR'); --TO_CHAR(AK.START_DATE,'MM/DD/YYYY');
            v_plan_end_date := to_char(l_old_end_date, 'MM/DD/RRRR'); --TO_CHAR(AK.END_DATE,'MM/DD/YYYY');

            for ak in (
                select
                    a.name,
                    b.acc_num,
                    b.broker_id,
                    b.ga_id,
                    pc_broker.get_broker_name(b.broker_id)        broker_name,
                    pc_sales_team.get_general_agent_name(b.ga_id) ga_name,
                    pc_account.get_salesrep_name(b.salesrep_id)   rep_name,
                    to_char(b.start_date, 'MM/DD/YYYY')           plan_start_date,
                    to_char(b.end_date, 'MM/DD/YYYY')             plan_end_date,
                    b.plan_code,
                    a.no_of_eligible,
                    'COBRA',
                    a.entrp_id,
                    b.acc_id,
                    pc_lookups.get_account_status(account_status)
                from
                    enterprise a,
                    account    b
                where
                        a.entrp_id = b.entrp_id
                    and b.acc_id = l_ben_plan_new(i).acc_id
            ) loop
                v_old_data := 'Y';
                v_emp_name := ak.name;
                v_acc_num := ak.acc_num;
                v_broker_id := ak.broker_id;
                v_ga_id := ak.ga_id;
                v_rep_name := ak.rep_name;
                v_entrp_id := ak.entrp_id;
                v_plan_type := 'COBRA';
                       --V_BATCH_NUMBER         :=  AK.RENEWAL_BATCH_NUMBER;
                v_broker_name := ak.broker_name;
                v_ga_name := ak.ga_name;
            end loop;

            for k in (
                select
                    c.line_list_price price,
                    rpd.coverage_type,
                    pc_lookups.get_meaning(
                        upper(payment_method),
                        'PAYMENT_METHOD'
                    )                 payment_method
                from
                    ar_quote_headers b,
                    ar_quote_lines   c,
                    rate_plan_detail rpd
                where
                        c.rate_plan_detail_id = rpd.rate_plan_detail_id
                    and b.quote_header_id = c.quote_header_id
                    and b.batch_number = l_ben_plan_new(i).batch_number
                    and b.entrp_id = l_ben_plan_new(i).entrp_id
            ) loop
                if k.coverage_type = 'MAIN_COBRA_SERVICE' then
                    v_renewal_fee := k.price;
                end if;
                if k.coverage_type = 'OPTIONAL_COBRA_SERVICE_CN' then
                    v_carrier_notif := k.price;
                end if;
                if k.coverage_type = 'OPEN_ENROLLMENT_SUITE' then
                    v_open_enrll_suite := k.price;
                end if;

                  /*Modified on 23/04/18 for ticket#5520 */
                if k.coverage_type = 'OPTIONAL_COBRA_SERVICE_SC' then
                    v_state_new := k.price;
                end if;
                v_pay_method := k.payment_method;
            end loop;

            for j in (
                select --WM_CONCAT(FIRST_NAME) FIRST_NAME FROM
                    listagg(first_name, ',') within group(
                    order by
                        first_name
                    ) first_name
                from
                    (
                        select distinct
                            first_name first_name
                        from
                            contact_leads
                        where
                                contact_type = 'BROKER'
                                --AND REF_ENTITY_ID    = L_BEN_PLAN_NEW(I).BATCH_NUMBER
                            and entity_id = pc_entrp.get_tax_id(l_ben_plan_new(i).entrp_id)--Ticket#4408(All contacts associated for thsi Broker should be displayed)
                            and ref_entity_type = 'BEN_PLAN_RENEWALS'
                    )
            ) loop
                v_broker_contact := j.first_name;
            end loop;

            for j in (
                select --WM_CONCAT(FIRST_NAME) FIRST_NAME FROM
                    listagg(first_name, ',') within group(
                    order by
                        first_name
                    ) first_name
                from
                    (
                        select distinct
                            first_name first_name
                        from
                            contact_leads
                        where
                                contact_type = 'GA'
                                --AND REF_ENTITY_ID    = L_BEN_PLAN_NEW(I).BATCH_NUMBER
                            and entity_id = pc_entrp.get_tax_id(l_ben_plan_new(i).entrp_id)--Ticket#4408
                            and ref_entity_type = 'BEN_PLAN_RENEWALS'
                    )
            ) loop
                v_ga_contact := j.first_name;
            end loop;

            for j in (
                select
                    agency_name
                from
                    external_sales_team_leads
                where
                        entity_type = 'BROKER'
                    and entrp_id = l_ben_plan_new(i).entrp_id
                    and ref_entity_id = l_ben_plan_new(i).batch_number
                    and ref_entity_type = 'BEN_PLAN_RENEWALS'
            ) loop
                l_ben_plan_new(i).broker_name := j.agency_name;
                dbms_output.put_line('Broker Name' || j.agency_name);
            end loop;

            for j in (
                select
                    agency_name
                from
                    external_sales_team_leads
                where
                        entity_type = 'GA'
                    and entrp_id = l_ben_plan_new(i).entrp_id
                    and ref_entity_id = l_ben_plan_new(i).batch_number
                    and ref_entity_type = 'BEN_PLAN_RENEWALS'
            ) loop
                l_ben_plan_new(i).ga_name := j.agency_name;
            end loop;

            gen_xl_xml.set_column_width(1, 150, v_work_sheet);
              --Plan Setup Work sheet Header
            gen_xl_xml.write_cell_char(1, r, v_work_sheet, 'Employer Name', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_char(1,
                                       r + 1,
                                       v_work_sheet,
                                       pc_entrp.get_entrp_name(l_ben_plan_new(i).entrp_id)
                                       || '('
                                       || l_ben_plan_new(i).acc_num
                                       || ')',
                                       'BEN_PLAN_COLUMN');

            gen_xl_xml.write_cell_null(1, r + 2, v_work_sheet, 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_null(2, r, v_work_sheet, 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                 --GEN_XL_XML.WRITE_CELL_CHAR( 2,  R+1, V_WORK_SHEET , 'Renewed Plan',  'BEN_PLAN_HEADER_BEN_PLAN1' );
                gen_xl_xml.write_cell_null(2, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            else
                gen_xl_xml.write_cell_char(2, r + 1, v_work_sheet, 'Renewed Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
                gen_xl_xml.write_cell_char(2, r + 2, v_work_sheet, 'Previous Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
            end if;

            gen_xl_xml.write_cell_char(3, r, v_work_sheet, 'Product', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(3, r + 1, v_work_sheet, 'COBRA', 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(3, r + 2, v_work_sheet, 'COBRA', 'BEN_PLAN_COLUMN');
            gen_xl_xml.write_cell_char(4, r, v_work_sheet, 'Broker Name', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(4,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).broker_name,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).broker_name,
                       'S') != nvl(v_broker_name, 'S') then
                    gen_xl_xml.write_cell_char(4,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).broker_name,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(4, r + 2, v_work_sheet, v_broker_name, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(4,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).broker_name,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(4, r + 2, v_work_sheet, v_broker_name, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(5, r, v_work_sheet, 'GA', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(5,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).ga_name,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).ga_name,
                       'S') != nvl(v_ga_name, 'S') then
                    gen_xl_xml.write_cell_char(5,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ga_name,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(5, r + 2, v_work_sheet, v_ga_name, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(5,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ga_name,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(5, r + 2, v_work_sheet, v_ga_name, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(6, r, v_work_sheet, 'Sales rep', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(6,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).rep_name,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).rep_name,
                       'S') != nvl(v_rep_name, 'S') then
                    gen_xl_xml.write_cell_char(6,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).rep_name,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(6, r + 2, v_work_sheet, v_rep_name, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(6,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).rep_name,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(6, r + 2, v_work_sheet, v_rep_name, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(7, r, v_work_sheet, 'Start Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(7,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).plan_start_date,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).plan_start_date,
                       'S') != nvl(v_plan_start_date, 'S') then
                    gen_xl_xml.write_cell_char(7,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_start_date,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(7, r + 2, v_work_sheet, v_plan_start_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(7,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_start_date,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(7, r + 2, v_work_sheet, v_plan_start_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(8, r, v_work_sheet, 'End Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(8,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).plan_end_date,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).plan_end_date,
                       'S') != nvl(v_plan_end_date, 'S') then
                    gen_xl_xml.write_cell_char(8,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_end_date,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(8, r + 2, v_work_sheet, v_plan_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(8,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_end_date,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(8, r + 2, v_work_sheet, v_plan_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(9, r, v_work_sheet, 'Total COBRA Eligible Employees', 'BEN_PLAN_HEADER');
          /*    IF V_OLD_DATA = 'N' THEN
                 GEN_XL_XML.WRITE_CELL_NUM( 9, R+1, V_WORK_SHEET , L_BEN_PLAN_NEW(I).NO_OF_ELIGIBLE, 'BEN_PLAN_COLUMN' );
              ELSE
                 IF NVL(L_BEN_PLAN_NEW(I).NO_OF_ELIGIBLE,-1) != NVL(V_NO_OF_ELIGIBLE_OLD,-1) THEN
                    GEN_XL_XML.WRITE_CELL_NUM( 9,  R+1, V_WORK_SHEET , L_BEN_PLAN_NEW(I).NO_OF_ELIGIBLE, 'BEN_PLAN_COLUMN_CHG' );
                    GEN_XL_XML.WRITE_CELL_NUM( 9,  R+2, V_WORK_SHEET , V_NO_OF_ELIGIBLE_OLD, 'BEN_PLAN_COLUMN_CHG' );
                 ELSE
                    GEN_XL_XML.WRITE_CELL_NUM( 9,  R+1, V_WORK_SHEET , L_BEN_PLAN_NEW(I).NO_OF_ELIGIBLE, 'BEN_PLAN_COLUMN' );
                    GEN_XL_XML.WRITE_CELL_NUM( 9,  R+2, V_WORK_SHEET , V_NO_OF_ELIGIBLE_OLD, 'BEN_PLAN_COLUMN' );
                 END IF;
              END IF;*/

            gen_xl_xml.write_cell_char(10, r, v_work_sheet, 'Renewal Amount', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(10,
                                          r + 1,
                                          v_work_sheet,
                                          nvl(v_renewal_fee, 0),
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(v_renewal_fee, 0) != nvl(v_renewal_fee_old, 0) then
                    gen_xl_xml.write_cell_num(10,
                                              r + 1,
                                              v_work_sheet,
                                              nvl(v_renewal_fee, 0),
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(10,
                                              r + 2,
                                              v_work_sheet,
                                              nvl(v_renewal_fee_old, 0),
                                              'BEN_PLAN_COLUMN_CHG');

                else
                    gen_xl_xml.write_cell_num(10,
                                              r + 1,
                                              v_work_sheet,
                                              nvl(v_renewal_fee, 0),
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(10,
                                              r + 2,
                                              v_work_sheet,
                                              nvl(v_renewal_fee_old, 0),
                                              'BEN_PLAN_COLUMN');

                end if;
            end if;

            gen_xl_xml.write_cell_char(11, r, v_work_sheet, 'Carrier Notifications', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(11,
                                          r + 1,
                                          v_work_sheet,
                                          nvl(v_carrier_notif, 0),
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(v_carrier_notif, 0) != nvl(v_carrier_notif_old, 0) then
                    gen_xl_xml.write_cell_num(11,
                                              r + 1,
                                              v_work_sheet,
                                              nvl(v_carrier_notif, 0),
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(11,
                                              r + 2,
                                              v_work_sheet,
                                              nvl(v_carrier_notif_old, 0),
                                              'BEN_PLAN_COLUMN_CHG');

                else
                    gen_xl_xml.write_cell_num(11,
                                              r + 1,
                                              v_work_sheet,
                                              nvl(v_carrier_notif, 0),
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(11,
                                              r + 2,
                                              v_work_sheet,
                                              nvl(v_carrier_notif_old, 0),
                                              'BEN_PLAN_COLUMN');

                end if;
            end if;

            gen_xl_xml.write_cell_char(12, r, v_work_sheet, 'Open Enrollment Suite', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(12,
                                          r + 1,
                                          v_work_sheet,
                                          nvl(v_open_enrll_suite, 0),
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(v_open_enrll_suite, 0) != nvl(v_open_enrll_suite_old, 0) then
                    gen_xl_xml.write_cell_num(12,
                                              r + 1,
                                              v_work_sheet,
                                              nvl(v_open_enrll_suite, 0),
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(12,
                                              r + 2,
                                              v_work_sheet,
                                              nvl(v_open_enrll_suite_old, 0),
                                              'BEN_PLAN_COLUMN_CHG');

                else
                    gen_xl_xml.write_cell_num(12,
                                              r + 1,
                                              v_work_sheet,
                                              nvl(v_open_enrll_suite, 0),
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(12,
                                              r + 2,
                                              v_work_sheet,
                                              nvl(v_open_enrll_suite_old, 0),
                                              'BEN_PLAN_COLUMN');

                end if;
            end if;

              /*Modified for ticket#5520 on 23/04/18 */
            gen_xl_xml.write_cell_char(13, r, v_work_sheet, 'State Continuation', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(13,
                                          r + 1,
                                          v_work_sheet,
                                          nvl(v_state_old, 0),
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(v_state_new, 0) != nvl(v_state_old, 0) then
                    gen_xl_xml.write_cell_num(13,
                                              r + 1,
                                              v_work_sheet,
                                              nvl(v_state_new, 0),
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(13,
                                              r + 2,
                                              v_work_sheet,
                                              nvl(v_state_old, 0),
                                              'BEN_PLAN_COLUMN_CHG');

                else
                    gen_xl_xml.write_cell_num(13,
                                              r + 1,
                                              v_work_sheet,
                                              nvl(v_state_new, 0),
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(13,
                                              r + 2,
                                              v_work_sheet,
                                              nvl(v_state_old, 0),
                                              'BEN_PLAN_COLUMN');

                end if;
            end if;

                 /*Modified for ticket#5520 on 23/04/18 */

            gen_xl_xml.write_cell_char(14, r, v_work_sheet, 'Payment Method', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(14, r + 1, v_work_sheet, v_pay_method, 'BEN_PLAN_COLUMN');
            else
                if nvl(v_pay_method, -1) != nvl(v_pay_method_old, -1) then
                    gen_xl_xml.write_cell_char(14, r + 1, v_work_sheet, v_pay_method, 'BEN_PLAN_COLUMN_CHG');
                    gen_xl_xml.write_cell_char(14, r + 2, v_work_sheet, v_pay_method_old, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(14, r + 1, v_work_sheet, v_pay_method, 'BEN_PLAN_COLUMN');
                    gen_xl_xml.write_cell_char(14, r + 2, v_work_sheet, v_pay_method_old, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            gen_xl_xml.write_cell_char(15, r, v_work_sheet, 'Broker Contact', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(15,
                                       r + 1,
                                       v_work_sheet,
                                       replace(
                                replace(v_broker_contact, '>', ''),
                                '<',
                                ''
                            ),
                                       'BEN_PLAN_COLUMN');

            gen_xl_xml.write_cell_char(16, r, v_work_sheet, 'GA Contact', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(16,
                                       r + 1,
                                       v_work_sheet,
                                       replace(
                                replace(v_ga_contact, '>', ''),
                                '<',
                                ''
                            ),
                                       'BEN_PLAN_COLUMN');

            gen_xl_xml.close_file;
            if file_exists(v_file_name, 'MAILER_DIR') = 'TRUE' then

/*             V_HTML_MSG  := '<html><body><br>
                     <p>Daily Cobra Renewal Changes Report for the Date '||TO_CHAR(SYSDATE,'MM/DD/YYYY')||' </p> <br> <br>
                      </body></html>';
*/                      
             --Added code by sekhar for Ticket #12544
                v_html_msg := '<html><body><br>
                     <p>Cobra Renewal Changes Report for the '
                              || v_acc_num
                              || ' </p> <br> <br>
                      </body></html>';
                v_email := null;
                if user = 'SAM' then
                   --Added code by sekhar for Ticket #12544
                    v_email := pc_sales_team.get_cust_srvc_rep_email_for_er(p_entrp_id => v_entrp_id);
                    if v_email is null then
                        v_email := 'COBRA@sterlingadministration.com';
                    else
                        v_email := v_email
                                   || ','
                                   || 'COBRA@sterlingadministration.com';
                    end if;

                else
                    v_email := 'it-team@sterlingadministration.com,Sekhar.Reddy@sterlingadministration.com';
                end if;

                mail_utility.send_file_in_emails(
                    p_from_email   => 'oracle@sterlinghsa.com',
                    p_to_email     => v_email,
                    p_file_name    => v_file_name,
                    p_sql          => null,
                    p_html_message => v_html_msg
--                                           ,  P_REPORT_TITLE => 'Daily Cobra Renewal Changes Report for the Date '||TO_CHAR(SYSDATE,'MM/DD/YYYY')
                    ,
                    p_report_title => v_acc_num
                                      || '_'
                                      || 'Cobra Renewal Changes Report'
                                      || '_'
                                      || to_char(sysdate, 'MMDDYYYY')
                );   --Added code by sekhar for Ticket #12544
            end if;

            if
                p_acc_id is not null
                and v_file_name is not null
            then
                pc_crm_interface.export_changes_report(p_acc_id, v_file_name);
            end if;

        end loop;

    exception
        when no_data_found then
            dbms_output.put_line('ERROR '
                                 || ' '
                                 || sqlerrm
                                 || ' '
                                 || sqlcode);
        when others then
            dbms_output.put_line('ERROR '
                                 || ' '
                                 || sqlerrm
                                 || ' '
                                 || sqlcode);

            raise;
    end pos_renewal_det_cobra;

    procedure create_aca_eligibility (
        p_ben_plan_id                 in number,
        p_aca_ale_flag                in varchar2,
        p_variable_hour_flag          in varchar2,
        p_irs_lbm_flag                in varchar2,
        p_intl_msrmnt_period          in varchar2,
        p_intl_msrmnt_start_date      in varchar2,
        p_intl_admn_period            in varchar2,
        p_stblty_period               in varchar2,
           /*Ticket#5518 */
        p_fte_hrs                     in varchar2,
        p_fte_salary_msmrt_period     in varchar2,
        p_fte_hourly_msmrt_period     in varchar2,
        p_fte_other_msmrt_period      in varchar2,
        p_fte_other_ee_name           in varchar2,
        /*--LookkBack Method */
        p_fte_look_back               in varchar2,
        p_fte_lkp_salary_msmrt_period in varchar2,
        p_fte_lkp_hourly_msmrt_period in varchar2,
        p_fte_lkp_other_msmrt_period  in varchar2,
        p_fte_lkp_other_ee_name       in varchar2,
	/*Lookback end */
        p_msrmnt_period               in varchar2,
        p_msrmnt_start_date           in varchar2,
        p_msrmnt_end_date             in varchar2,
        p_stblt_start_date            in varchar2,
        p_stblt_period                in varchar2,
        p_stblt_end_date              in varchar2,
        p_fte_same_period_resume_date in varchar2,
        p_fte_diff_period_resume_date in varchar2,
          /*Ticket#5518 */
        p_admn_start_date             in varchar2,
        p_admn_period                 in varchar2,
        p_admn_end_date               in varchar2,
        p_mnthl_msrmnt_flag           in varchar2,
        p_same_prd_bnft_start_date    in varchar2,
        p_new_prd_bnft_start_date     in varchar2,
        p_user_id                     in number,
        p_entrp_id                    in number,
        p_fte_same_period_select      in varchar2 default null,  -- Added by swamy for Ticket#6228
        p_fte_diff_period_select      in varchar2 default null,  --  Added by swamy for Ticket#6228
        p_define_intl_msrmnt_period   in varchar2 default null,  --  Added by swamy for Ticket#8684 on 19/05/2020
        x_error_status                out varchar2,
        x_error_message               out varchar2
    ) is
        l_acc_id number;
    begin
        pc_log.log_error('PC_WEB_ER_RENEWAL.ERISA ACA Eligibility', 'In Proc');
        insert into erisa_aca_eligibility (
            eligibility_id,
            ben_plan_id,
            aca_ale_flag,
            variable_hour_flag,
            intl_msrmnt_period,
            intl_msrmnt_start_date,
            intl_admn_period,
            stblty_period,
            msrmnt_start_date,
            msrmnt_period,
            msrmnt_end_date,
            admn_start_date,
            admn_period,
            admn_end_date,
            stblt_start_date,
            stblt_period,
            stblt_end_date,
            irs_lbm_flag,
            mnthl_msrmnt_flag,
            same_prd_bnft_start_date,
            new_prd_bnft_start_date,
            fte_hrs,
            fte_look_back,
            fte_salary_msmrt_period,
            fte_hourly_msmrt_period,
            fte_other_msmrt_period,
            fte_same_period_resume_date,
            fte_diff_period_resume_date,
            fte_lkp_salary_msmrt_period,
            fte_lkp_hourly_msmrt_period,
            fte_lkp_other_msmrt_period,
            fte_lkp_other_ee_detail,
            fte_other_ee_detail,
            fte_same_period_select,     -- Added by swamy for Ticket#6228
            fte_diff_period_select,     -- Added by swamy for Ticket#6228
            define_intl_msrmnt_period,  --  Added by swamy for Ticket#8684 on 19/05/2020
            created_by,
            creation_date,
            last_updated_by,
            last_update_date
        ) values ( erisa_aca_seq.nextval,
                   p_ben_plan_id,
                   p_aca_ale_flag,
                   p_variable_hour_flag,
                   p_intl_msrmnt_period,
                   to_date(p_intl_msrmnt_start_date, 'mm/dd/rrrr'),
                   p_intl_admn_period,
                   p_stblty_period,
                   to_date(p_msrmnt_start_date, 'mm/dd/rrrr'),
                   p_msrmnt_period,
                   to_date(p_msrmnt_end_date, 'mm/dd/rrrr'),
                   to_date(p_admn_start_date, 'mm/dd/rrrr'),
                   p_admn_period,
                   to_date(p_admn_end_date, 'mm/dd/rrrr'),
                   to_date(p_stblt_start_date, 'mm/dd/rrrr'),
                   p_stblt_period,
                   to_date(p_stblt_end_date, 'mm/dd/rrrr'),
                   p_irs_lbm_flag,
                   p_mnthl_msrmnt_flag,
                   to_date(p_same_prd_bnft_start_date, 'mm/dd/rrrr'),
                   to_date(p_new_prd_bnft_start_date, 'mm/dd/rrrr'),
                   p_fte_hrs,
                   p_fte_look_back,
                   p_fte_salary_msmrt_period,
                   p_fte_hourly_msmrt_period,
                   p_fte_other_msmrt_period,
                   p_fte_same_period_resume_date  -- Date field altered to varchar2 field wrt Ticket#6663 by Swamy on 31/08/2018   -- 6147 eligibility record is not getting created. Joshi
                   ,
                   p_fte_diff_period_resume_date  -- Date field altered to varchar2 field wrt Ticket#6663 by Swamy on 31/08/2018
                   ,
                   p_fte_lkp_salary_msmrt_period,
                   p_fte_lkp_hourly_msmrt_period,
                   p_fte_lkp_other_msmrt_period,
                   p_fte_lkp_other_ee_name,
                   p_fte_other_ee_name,
                   p_fte_same_period_select     -- Added by swamy for Ticket#6228
                   ,
                   p_fte_diff_period_select     -- Added by swamy for Ticket#6228
                   ,
                   p_define_intl_msrmnt_period  --  Added by swamy for Ticket#8684 on 19/05/2020
                   ,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   sysdate );

    exception
        when others then
            pc_log.log_error('PC_WEB_ER_RENEWAL.ERISA ACA Eligibility', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end create_aca_eligibility;

    procedure process_renewal_staging (
        p_batch_num                      in number,
        p_entrp_id                       in number,
        p_user_id                        in number,
        p_pay_acct_fees                  in varchar2,
        p_invoice_flag                   in varchar2,
        p_bank_name                      in varchar2,
        p_routing_num                    in varchar2,
        p_account_type                   in varchar2,
        p_account_num                    in varchar2,
        p_fund_option                    in varchar2,
        p_bank_authorize                 in varchar2,              -- Added by Jaggi ##9602
        p_payment_method                 in varchar2,     -- Added by Swamy for Ticket#1119
        p_bank_name_monthly              in varchar2,    -- Added by Jaggi #11263
        p_routing_num_monthly            in varchar2,    -- Added by Jaggi #11263
        p_account_type_monthly           in varchar2,    -- Added by Jaggi #11263
        p_account_num_monthly            in varchar2,    -- Added by Jaggi #11263
        p_pay_monthly_fees_by            in varchar2,    -- Added by Jaggi #11263
        p_monthly_fee_payment_method     in varchar2,    -- Added by Jaggi #11263
        p_giac_response                  in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_verify                    in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_authenticate              in varchar2,   -- Added by Swamy for Ticket#12309 
        p_bank_acct_verified             in varchar2,   -- Added by Swamy for Ticket#12309 
        p_business_name                  in varchar2,   -- Added by Swamy for Ticket#12309 
        p_bank_status                    in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_response_monthly          in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_verify_monthly            in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_authenticate_monthly      in varchar2,   -- Added by Swamy for Ticket#12309 
        p_bank_acct_verified_monthly     in varchar2,   -- Added by Swamy for Ticket#12309 
        p_business_name_monthly          in varchar2,   -- Added by Swamy for Ticket#12309 
        p_bank_status_monthly            in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_verified_response         in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_verified_response_monthly in varchar2,   -- Added by Swamy for Ticket#12309 
        x_enrollment_id                  out number,
        x_error_status                   out varchar2,
        x_error_message                  out varchar2
    ) is

        l_acc_num       varchar2(100);
        l_tax_id        varchar2(100);
        l_bank_id       number;
        l_return_status varchar2(10);
        l_error_message varchar2(2000);
        l_cnt           number := 0;
    begin
        pc_log.log_error('process_renewal_staging', 'p_entrp_id :='
                                                    || p_entrp_id
                                                    || 'P_Batch_Num'
                                                    || p_batch_num
                                                    || ' p_giac_verify :='
                                                    || p_giac_verify
                                                    || ' p_giac_authenticate :='
                                                    || p_giac_authenticate
                                                    || ' p_giac_response :='
                                                    || p_giac_response);  -- Added by Swamy for Ticket#12309
        pc_log.log_error('process_renewal_staging', 'p_giac_response_monthly'
                                                    || p_giac_response_monthly
                                                    || ' p_giac_authenticate_monthly :='
                                                    || p_giac_authenticate_monthly
                                                    || ' p_bank_acct_verified_monthly :='
                                                    || p_bank_acct_verified_monthly
                                                    || ' p_giac_verified_response_monthly :='
                                                    || p_giac_verified_response_monthly);  -- Added by Swamy for Ticket#12309

        select
            acc_num,
            entrp_code
        into
            l_acc_num,
            l_tax_id
        from
            account    a,
            enterprise b
        where
                b.entrp_id = p_entrp_id
            and a.entrp_id = b.entrp_id;

        pc_log.log_error('process_renewal_staging', 'Entrp ID' || 'After Select');
        pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments4 l_pay_acct_fees number', p_pay_acct_fees);
    -- if new plan is added while renewing, there will be record already in the staging table so we need to check and then update accordingly
    -- Added by Joshi for 11263.

        for x in (
            select
                count(*) cnt
            from
                online_fsa_hra_staging
            where
                    batch_number = p_batch_num
                and entrp_id = p_entrp_id
                and nvl(source, '*') = 'RENEWAL'
        ) loop
            l_cnt := x.cnt;
        end loop;

        if l_cnt = 0 then
            insert into online_fsa_hra_staging (
                enrollment_id,
                entrp_id,
                acc_num,
                company_name,
                pay_acct_fees,
                invoice_flag,
                bank_name,
                routing_number,
                bank_acc_num,
                bank_acc_type,
                acct_usage,
                fund_option,
                bank_authorize,
                batch_number,
                source,
                created_by,
                creation_date,
                payment_method,             -- Added by Swamy for Ticket#1119
                monthly_fees_paid_by,       -- Added by Jaggi #11263
                monthly_fee_payment_method, -- Added by Jaggi #11263
                monthly_bank_name,          -- Added by Jaggi #11263
                monthly_routing_number,     -- Added by Jaggi #11263
                monthly_bank_acc_num,       -- Added by Jaggi #11263
                monthly_bank_acc_type,       -- Added by Jaggi #11263
                giac_response,       -- Start Added by Swamy for Ticket#12309
                giac_verify,
                giac_authenticate,
                bank_acct_verified,
                business_name,
                bank_status,
                giac_response_monthly,
                giac_verify_monthly,
                giac_authenticate_monthly,
                bank_acct_verified_monthly,
                business_name_monthly,
                giac_verified_response,
                giac_verified_response_monthly,
                bank_status_monthly   -- End Added by Swamy for Ticket#12309      
            ) values ( fsa_online_enroll_seq.nextval,
                       p_entrp_id,
                       l_acc_num,
                       pc_employer_enroll.get_company_name(l_tax_id),
                       upper(p_pay_acct_fees),
                       p_invoice_flag,
                       p_bank_name,
                       p_routing_num,
                       p_account_num,
                       p_account_type,
                       'INVOICE',
                       p_fund_option,
                       p_bank_authorize,
                       p_batch_num,
                       'RENEWAL',
                       p_user_id,
                       sysdate,
                       p_payment_method,             -- Added by Swamy for Ticket#1119
                       p_pay_monthly_fees_by,        -- Added by Jaggi #11263
                       p_monthly_fee_payment_method, -- Added by Jaggi #11263
                       p_bank_name_monthly,          -- Added by Jaggi #11263
                       p_routing_num_monthly,        -- Added by Jaggi #11263
                       p_account_num_monthly,        -- Added by Jaggi #11263
                       p_account_type_monthly,       -- Added by Jaggi #11263
                       p_giac_response,       -- Start Added by Swamy for Ticket#12309
                       p_giac_verify,
                       p_giac_authenticate,
                       p_bank_acct_verified,
                       p_business_name,
                       p_bank_status,
                       p_giac_response_monthly,
                       p_giac_verify_monthly,
                       p_giac_authenticate_monthly,
                       p_bank_acct_verified_monthly,
                       p_business_name_monthly,
                       p_giac_verified_response,
                       p_giac_verified_response_monthly,
                       p_bank_status_monthly    -- End Added by Swamy for Ticket#12309
                        ) returning enrollment_id into x_enrollment_id;

        else
            update online_fsa_hra_staging
            set
                company_name = pc_employer_enroll.get_company_name(l_tax_id),
                pay_acct_fees = upper(p_pay_acct_fees),
                invoice_flag = p_invoice_flag,
                bank_name = p_bank_name,
                routing_number = p_routing_num,
                bank_acc_num = p_account_num,
                bank_acc_type = p_account_type,
                acct_usage = 'INVOICE',
                fund_option = p_fund_option,
                bank_authorize = p_bank_authorize,
                payment_method = p_payment_method,             -- Added by Swamy for Ticket#1119
                monthly_fees_paid_by = p_pay_monthly_fees_by,       -- Added by Jaggi #11263
                monthly_fee_payment_method = p_monthly_fee_payment_method, -- Added by Jaggi #11263
                monthly_bank_name = p_bank_name_monthly,          -- Added by Jaggi #11263
                monthly_routing_number = p_routing_num_monthly,     -- Added by Jaggi #11263
                monthly_bank_acc_num = p_account_num_monthly,       -- Added by Jaggi #11263
                monthly_bank_acc_type = p_account_type_monthly,
                giac_response = nvl(p_giac_response, giac_response),   -- Added by Swamy for Ticket#12309 
                giac_verify = nvl(p_giac_verify, giac_verify),   -- Added by Swamy for Ticket#12309 
                giac_authenticate = nvl(p_giac_authenticate, giac_authenticate),   -- Added by Swamy for Ticket#12309 
                bank_acct_verified = nvl(p_bank_acct_verified, bank_acct_verified),   -- Added by Swamy for Ticket#12309 
                business_name = nvl(p_business_name, business_name),   -- Added by Swamy for Ticket#12309    
                bank_status = nvl(p_bank_status, bank_status),
                giac_response_monthly = nvl(p_giac_response_monthly, giac_response_monthly),   -- Added by Swamy for Ticket#12309 
                giac_verify_monthly = nvl(p_giac_verify_monthly, giac_verify_monthly),   -- Added by Swamy for Ticket#12309 
                giac_authenticate_monthly = nvl(p_giac_authenticate_monthly, giac_authenticate_monthly),   -- Added by Swamy for Ticket#12309 
                bank_acct_verified_monthly = nvl(p_bank_acct_verified_monthly, bank_acct_verified_monthly),   -- Added by Swamy for Ticket#12309 
                business_name_monthly = nvl(p_business_name_monthly, business_name_monthly),   -- Added by Swamy for Ticket#12309    
                bank_status_monthly = nvl(p_bank_status_monthly, bank_status_monthly),
                giac_verified_response = nvl(p_giac_verified_response, giac_verified_response),
                giac_verified_response_monthly = nvl(p_giac_verified_response_monthly, giac_verified_response_monthly)
            where
                    batch_number = p_batch_num
                and entrp_id = p_entrp_id
                and nvl(source, '*') = 'RENEWAL'
            returning enrollment_id into x_enrollment_id;

        end if;

        pc_log.log_error('process_renewal_staging end..', x_enrollment_id);
    exception
        when others then
            pc_log.log_error('process_renewal_staging', sqlerrm);
    end process_renewal_staging;

/*Ticket#5020.POP Renewal*/
    procedure populate_renewal_data (
        p_batch_number in number,
        p_entrp_id     in number,
        p_plan_id      in number,
        p_user_id      in number
    ) is

        l_cnt                   number;
        l_renewed_plan_id       number;
        l_batch_number          number; --- 7832 rprabu 04/06/2019
        l_plan_type             varchar2(100);
        l_cnt_contact           number;
        l_cnt_ga                number;
        l_ga_lic                varchar2(100);
        l_affl_flag             varchar2(2) := 'N';
        l_cntrl_grp             varchar2(2) := 'N';
        l_renewal_resubmit_flag varchar2(1); -- Added by jaggi for Ticket#10431
        l_bank_name             varchar2(255);          -- Start Added by Swamy for Ticket# 10747
        l_bank_routing_num      varchar2(255);
        l_bank_acct_num         varchar2(255);
        l_bank_acct_type        varchar2(255);
        l_acc_id                number;
        l_user_type             varchar2(255);         -- End of Addition by Swamy for Ticket# 10747
        x_user_bank_acct_stg_id number;
        x_error_status          varchar2(255);
        x_error_message         varchar2(255);
        l_plan_id               number;
        l_request_id            number;
        l_bank_staging_id       number;
        l_account_type          varchar2(20);
        l_fees_payment_flag     varchar2(20);
    begin
        pc_log.log_error('In Populate renewal', p_batch_number);
        l_acc_id := pc_entrp.get_acc_id(p_entrp_id);
        select
            count(*)
        into l_cnt
        from
            online_compliance_staging
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number
            and source = 'RENEWAL';

        for k in (
            select
                renewal_resubmit_flag,
                a.account_type
            from
                account    a,
                enterprise b
            where
                    b.entrp_id = p_entrp_id
                and a.entrp_id = b.entrp_id
        ) loop
            l_renewal_resubmit_flag := k.renewal_resubmit_flag;
            l_account_type := k.account_type;  -- Added by Swamy for Ticket#12675     
        end loop;

        pc_log.log_error('In Populate renewal', l_cnt);
        pc_log.log_error('In Populate renewal..PLAN ID', p_plan_id);
        if l_cnt = 0 then

      -- Added by Swamy for Ticket#12698
            pc_giact_validations.populate_giact_renewal_staging(
                p_batch_number         => p_batch_number,
                p_entrp_id             => p_entrp_id,
                p_user_id              => p_user_id,
                p_account_type         => 'POP',
                p_ben_plan_id          => p_plan_id,
                x_staging_bank_acct_id => l_bank_staging_id,
                x_return_status        => x_error_status,
                x_error_message        => x_error_message
            );	

     /*     
	 l_BANK_ACCT_NUM := NULL;  -- Added by Swamy for Ticket#12675     
      -- Added by Swamy for Ticket# 10747
      FOR k IN (SELECT user_type FROM online_users WHERE user_id = p_user_id) LOOP
         l_Acc_id := pc_entrp.get_acc_id(p_entrp_id);
         l_user_type := k.user_type;
         FOR j IN (Select UPPER(payment_method) payment_method From AR_QUOTE_HEADERS   where entrp_id = p_entrp_id and ben_plan_id = p_plan_id) LOOP
           l_fees_payment_flag :=  j.payment_method;
         END LOOP;

         IF NVL(k.user_type,'*') NOT IN ('B') THEN
            IF l_account_type <> 'POP' THEN  -- Added by Swamy for Ticket#12675     
                 FOR m IN (SELECT B.BANK_NAME,b.BANK_ROUTING_NUM,B.BANK_ACCT_NUM,B.BANK_ACCT_TYPE
                             FROM  USER_BANK_ACCT B
                            WHERE B.ACC_ID = l_Acc_id
                              AND STATUS = 'A'
                              AND BANK_ACCT_ID = (SELECT MAX(BANK_ACCT_ID)
                                                    FROM USER_BANK_ACCT
                                                   WHERE ACC_ID = B.ACC_ID
                                                     AND STATUS = 'A')) LOOP
                     l_BANK_NAME        :=  m.BANK_NAME;
                     l_BANK_ROUTING_NUM := m.BANK_ROUTING_NUM;
                     l_BANK_ACCT_NUM    := m.BANK_ACCT_NUM;
                     l_BANK_ACCT_TYPE   := m.BANK_ACCT_TYPE;
                 END LOOP;
           ELSE
               pc_log.log_error('In Populate renewal..PLAN l_fees_payment_flag:= ',l_fees_payment_flag);
                -- Added by Swamy for Ticket#12675      
               IF l_fees_payment_flag = 'ACH' THEN
                    FOR bank_rec IN (SELECT entity_id,entity_type,BANK_ACCT_NUM,JSON_OBJECT(
                       KEY 'entity_id'            VALUE b.entity_id,
                       KEY 'entity_type'          VALUE b.entity_type,
                       KEY 'bank_routing_number'  VALUE b.bank_routing_num,
                       KEY 'bank_acct_num'        VALUE b.bank_acct_num,
                       KEY 'bank_acct_id'         VALUE b.bank_acct_id,
                       KEY 'bank_name'            VALUE b.bank_name,
                       KEY 'display_name'         VALUE b.display_name,
                       KEY 'bank_account_type'    VALUE b.bank_acct_type,
                       KEY 'bank_account_usage'   VALUE b.bank_account_usage,
                       KEY 'business_name'        VALUE b.business_name,
                       KEY 'product_type'         VALUE 'POP',
                       KEY 'acc_id'               VALUE l_Acc_id,
                       KEY 'giac_response'        VALUE b.giac_response,
                       KEY 'giac_authenticate'    VALUE b.giac_authenticate, 
                       KEY 'giac_verify'          VALUE b.giac_verify, 
                       KEY 'business_name'        VALUE b.business_name, 
                       KEY 'fees_payment_flag'    VALUE l_fees_payment_flag,
                       KEY 'giac_bank_Account_verified'  VALUE b.giac_bank_Account_verified,
                       KEY 'bank_status'          VALUE b.status
                       ) bank_details
                    FROM bank_accounts b
                    WHERE b.entity_id = l_Acc_id
                      AND b.entity_type = 'ACCOUNT'
                      AND b.status = 'A'
                      AND b.bank_account_usage = 'INVOICE'    
                    ) 
                  LOOP
                    pc_log.log_error('In Populate renewal..bank_rec.entity_id  ID',bank_rec.entity_id||'bank_rec.entity_type :='||bank_rec.entity_type||'bank_rec.bank_details :='|| bank_rec.bank_details||' p_batch_number :='||p_batch_number);
                    pc_giact_validations.insert_website_api_requests
                            (p_entity_id          => bank_rec.entity_id
                            ,p_entity_type        => bank_rec.entity_type
                            ,p_request_body       => bank_rec.bank_details
                            ,p_response_body      => NULL
                            ,p_batch_number       => p_batch_number
                            ,p_user_id            => p_user_id
                            ,p_processed_flag     => 'N'
                            ,x_request_id         => l_request_id
                            ,x_return_status      => x_error_status
                            ,x_error_message      => x_error_message
                            );

                    pc_log.log_error('In Populate renewal..l_request_id ',l_request_id);
                    pc_giact_validations.insert_bank_accounts_staging
                        (p_acc_id            => l_Acc_id
                        ,p_entrp_id          => p_entrp_id
                        ,p_bank_details      => bank_rec.bank_details
                        ,p_batch_number      => p_batch_number
                        ,p_user_id            => p_user_id
                        ,p_website_api_request_id => l_request_id
                        ,p_account_type      => 'POP'
                        ,p_validity          => 'V'
                        ,x_bank_staging_id   => l_bank_staging_id
                        ,x_return_status     => x_error_status
                        ,x_error_message     => x_error_message
                        );

                        l_BANK_ACCT_NUM := bank_rec.BANK_ACCT_NUM;
                         pc_log.log_error('In Populate renewal..l_bank_staging_id ',l_bank_staging_id);
                  END LOOP;
             END IF;
       END IF;

         END IF;
      END LOOP;
      */
            insert into online_compliance_staging (
                record_id,
                entrp_id,
                no_off_ees,
                effective_date,
                state_of_org,
                fiscal_yr_end,
                type_of_entity,
                company_tax,         -- Added by jaggi ##9604
                batch_number,
      --  BANK_NAME     ,
     --   ROUTING_NUMBER,
     --   BANK_ACC_NUM  ,      
      --  BANK_ACC_TYPE ,
                remittance_flag,
                fees_payment_flag,      --8494 rprabu 17/12/2019
                acct_payment_fees,     --8494 rprabu 17/12/2019
                salesrep_flag,
                salesrep_id,
                send_invoice,
                entity_name_desc,
                org_eff_date,
                eff_date_sterling,
                no_of_eligible,
                affliated_flag,
                cntrl_grp_flag,
                source,
                created_by,
                creation_date,
                last_updated_by,
                state_main_office,     -- Start Added by swamy for Ticket#11037
                state_govern_law,
                affliated_diff_ein,
                type_entity_other     -- End of Addition by swamy for Ticket#11037
            )
                (
                    select
                        compliance_staging_seq.nextval,
                        p_entrp_id,
                        a.no_of_ees,
                        null effective_date,
                        state_of_org,
                        null fiscal_yr_end,
                        entity_type,
                        a.company_tax  -- Added by jaggi ##9604
                        ,
                        p_batch_number
           /*,(SELECT B.BANK_NAME FROM  USER_BANK_ACCT B WHERE B.ACC_ID = C.ACC_ID AND STATUS = 'A' AND
                        BANK_ACCT_ID = (SELECT MAX(BANK_ACCT_ID) FROM USER_BANK_ACCT WHERE ACC_ID = B.ACC_ID and STATUS = 'A')
             )BANK_NAME
           ,( SELECT B.BANK_ROUTING_NUM FROM  USER_BANK_ACCT B WHERE B.ACC_ID = C.ACC_ID AND STATUS = 'A' AND
              BANK_ACCT_ID = (SELECT MAX(BANK_ACCT_ID) FROM USER_BANK_ACCT WHERE ACC_ID = B.ACC_ID and STATUS = 'A')
             )BANK_ROUTING_NUM
           ,(SELECT B.BANK_ACCT_NUM FROM  USER_BANK_ACCT B WHERE B.ACC_ID = C.ACC_ID AND STATUS = 'A' AND
              BANK_ACCT_ID = (SELECT MAX(BANK_ACCT_ID) FROM USER_BANK_ACCT WHERE ACC_ID = B.ACC_ID and STATUS = 'A')
            )BANK_ACCT_NUM
           ,(SELECT B.BANK_ACCT_TYPE FROM  USER_BANK_ACCT B WHERE B.ACC_ID = C.ACC_ID AND STATUS = 'A' AND
              BANK_ACCT_ID = (SELECT MAX(BANK_ACCT_ID) FROM USER_BANK_ACCT WHERE ACC_ID = B.ACC_ID and STATUS = 'A')
             )BANK_ACCT_TYPE
             */     -- Commented by Swamy for Ticket# 10747
      --      , l_BANK_NAME          -- Added by Swamy for Ticket# 10747
       --     , l_BANK_ROUTING_NUM   -- Added by Swamy for Ticket# 10747
        --    , l_BANK_ACCT_NUM        -- Added by Swamy for Ticket# 10747
        --    , l_BANK_ACCT_TYPE     -- Added by Swamy for Ticket# 10747
                        ,
                        null remittance_flag,
                        (
                            select
                                payment_method
                            from
                                ar_quote_headers
                            where
                                    entrp_id = p_entrp_id
                                and ben_plan_id = p_plan_id
                        )    fees_payment_flag  --8494 rprabu 17/12/2019
                        ,
                        decode(l_user_type, 'B', null, b.fees_paid_by)  -- Decode added by swamy for Ticket#10747   --8494 rprabu 17/12/2019
                        ,
                        null salesrep_flag,
                        null salesrep_id,
                        null send_invoice,
                        null entity_name_desc,
                        null org_eff_date,
                        null eff_date_sterling,
                        a.no_of_eligible,
                        'N'  affliated_flag -- Removed default value 'N' with a.AFFLIATED_FLAG for ticket# /* Ticket#7151 */
                        ,
                        'N'  cntrl_grp_flag  /* Ticket#7151 */,
                        'RENEWAL',
                        p_user_id,
                        sysdate,
                        p_user_id,
                        a.state_main_office     -- Start Added by swamy for Ticket#11037
                        ,
                        a.state_govern_law,
                        a.affliated_diff_ein,
                        a.entity_type_other     -- End of Addition by swamy for Ticket#11037
                    from
                        enterprise         a,
                        account            c,
                        account_preference b  --8494 rprabu 17/12/2019
                    where
                            a.entrp_id = p_entrp_id --31482
                        and b.entrp_id = a.entrp_id    --8494 rprabu 17/12/2019
                        and a.en_code = 1
                        and a.entrp_id = c.entrp_id
     --   and b.acc_id = c.acc_id
                        and rownum < 2
                );

      /* Created Affliated Employer and Controlled Group data */
            for xx in (
                select
                    b.name,
                    a.entity_id,
                    b.entity_type_other,
                    b.entrp_code,
                    b.entity_type,
                    b.address,
                    b.city,
                    b.zip,
                    b.state
                from
                    entrp_relationships a,
                    enterprise          b
                where
                        a.entrp_id = p_entrp_id
                    and relationship_type = 'AFFILIATED_ER'
                    and a.entity_id = b.entrp_id
                    and b.en_code = 10
            ) loop
                pc_log.log_error('In Populate renewal..PLAN ID', 'Aff1');
                l_affl_flag := 'Y';
			  /*Creating Affliated Employer */
                insert into enterprise_staging (
                    entrp_stg_id,
                    entrp_id,
                    en_code,
                    name,
                    batch_number,
                    entity_type,
                    created_by,
                    creation_date,
                    affliated_entity_type_other,   -- Start Added by swamy for Ticket#11037
                    affliated_ein,
                    affliated_entity_type,
                    affliated_address,
                    affliated_city,
                    affliated_zip,
                    affliated_state              -- End of Addition by swamy for Ticket#11037
                ) values ( entrp_staging_seq.nextval,
                           p_entrp_id,
                           10,
                           xx.name,
                           p_batch_number,
                           'BEN_PLAN_RENEWALS' -----'ENTERPRISE'   BEN_PLAN_RENEWALS added and ENTERPRISE commented for Ticket #7816
                           ,
                           p_user_id,
                           sysdate,
                           xx.entity_type_other       -- Start Added by swamy for Ticket#11037
                           ,
                           xx.entrp_code,
                           xx.entity_type,
                           xx.address,
                           xx.city,
                           xx.zip,
                           xx.state                  -- End of Addition by swamy for Ticket#11037
                            );

            end loop;

         /* Created Affliated Employer and Controlled Group data */
            for xx in (
                select
                    b.name,
                    a.entity_id
                from
                    entrp_relationships a,
                    enterprise          b
                where
                        a.entrp_id = p_entrp_id
                    and relationship_type = 'CONTROLLED_GROUP'
                    and a.entity_id = b.entrp_id
                    and b.en_code = 11
            ) loop
			  /*Creating Controlled group Employer */
                l_cntrl_grp := 'Y';
                insert into enterprise_staging (
                    entrp_stg_id,
                    entrp_id,
                    en_code,
                    name,
                    batch_number,
                    entity_type,
                    created_by,
                    creation_date
                ) values ( entrp_staging_seq.nextval,
                           p_entrp_id,
                           11,
                           xx.name,
                           p_batch_number,
                           'BEN_PLAN_RENEWALS'   -----'ENTERPRISE'   BEN_PLAN_RENEWALS added and ENTERPRISE commented for Ticket #7816
                           ,
                           p_user_id,
                           sysdate );

            end loop;

            pc_log.log_error('In Populate renewal..PLAN ID', 'Befoer Plan');
            pc_log.log_error('In Populate renewal..FLAG1', l_affl_flag);
            pc_log.log_error('In Populate renewal..FLAG2', l_cntrl_grp);
            for i in (
                select
                    *
                from
                    ben_plan_enrollment_setup
                where
                    ben_plan_id = p_plan_id
            ) loop
                pc_log.log_error('In Populate renewal..PLAN loop', p_plan_id);
                update online_compliance_staging
                set
                    effective_date = to_char(i.effective_date, 'mm/dd/yyyy'),/*Ticket#7135 */
                    org_eff_date = to_char(i.original_eff_date, 'mm/dd/yyyy'),
                    affliated_flag = l_affl_flag,
                    cntrl_grp_flag = l_cntrl_grp,
                    fiscal_yr_end = decode(
                        pc_account.get_account_type(l_acc_id),
                        'POP',
                        to_char(
                                             add_months(i.fiscal_end_date, 12),
                                             'mm/dd/yyyy'
                                         ),
                        to_char(i.fiscal_end_date, 'mm/dd/yyyy')
                    ) -- Added by swmay for ticket#12131 -- Added by Jaggi #10743 POP fiscal yr end should freeze
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number;

            end loop;

    /*Ben Plan data */
            insert into compliance_plan_staging (
                plan_id,
                entity_id,
                ben_plan_id,
                plan_name,
                plan_type,
                plan_number,
                plan_start_date,
                plan_end_date,
                takeover_flag,
                batch_number,
                plan_doc_ndt_flag,  --- 7832 rprabu
                created_by,
                creation_date
            )
                (
                    select
                        compliance_plan_seq.nextval,
                        p_entrp_id,
                        ben_plan_id,
                        ben_plan_name,
                        plan_type,
                        ben_plan_number,
                        to_char((plan_end_date + 1), 'mm/dd/yyyy')  --,plan_start_date(Since we are renewing we calculate the renewed plan dates depending on previous yr end date)
                        ,
                        case
                            when plan_type = 'COMP_POP' then
                                to_char(add_months((plan_end_date + 1), 12) - 1,
                                        'mm/dd/yyyy') --plan_end_date
                            else
                                to_char(add_months((plan_end_date + 1), 60) - 1,
                                        'mm/dd/yyyy')
                        end plan_end_date,
                        takeover,
                        p_batch_number,
                        non_discrm_flag  -- 7832 rprabu
                        ,
                        p_user_id,
                        sysdate
                    from
                        ben_plan_enrollment_setup
                    where
                        ben_plan_id = p_plan_id
                );

            select
                plan_id,
                plan_type
            into
                l_renewed_plan_id,
                l_plan_type
            from
                compliance_plan_staging
            where
                    entity_id = p_entrp_id
                and batch_number = p_batch_number;

            pc_log.log_error('In Populate renewal..renewed Plan ID', l_renewed_plan_id);

       /**Pricing Information **/
            insert into ar_quote_headers_staging (
                quote_header_id,
                entrp_id,
                payment_method,
                total_quote_price,
                ben_plan_id,
                batch_number,
                account_type,
                created_by,
                creation_date
            )
                (
                    select
                        quote_header_id_seq.nextval,
                        p_entrp_id,
                        payment_method,
                        total_quote_price,
                        l_renewed_plan_id,
                        p_batch_number,
                        l_plan_type,
                        p_user_id,
                        sysdate
                    from
                        ar_quote_headers
                    where
                            entrp_id = p_entrp_id
                        and ben_plan_id = p_plan_id
                );

            pc_log.log_error('In Populate renewal..After AR Quote', 'AR p_plan_id := ' || p_plan_id);

     --UPDATE ONLINE_COMPLIANCE_STAGING
   --  SET fees_payment_flag = (SELECT payment_method from AR_QUOTE_HEADERS_STAGING where ENTRP_ID = p_entrp_id and ben_plan_id = p_plan_id )
    -- WHERE entrp_id = p_entrp_id
   --  and batch_number = p_batch_number;

            for j in (
                select
                    ben_plan_id
                from
                    compliance_plan_staging
                where
                    plan_id = p_plan_id
            ) loop
                l_plan_id := j.ben_plan_id;
            end loop;

     /** Eligibiity requirement Info */
            insert into custom_eligibility_staging (
                eligibility_id,
                entity_id,
                no_of_hrs_part_time,
                no_of_hrs_seasonal,
                no_of_hrs_current,
                new_ee_month_servc,
                collective_bargain_flag,
                union_ee_join_flag,
                plan_new_ee_join,
                select_entry_date_flag,
                min_age_req,
                automatic_enroll,
                revoke_elect_flag,
                cease_covg_flag,
                contrib_flag,
                contrib_amt,
                percent_contrib,
                permit_cash_flag,
                limit_cash_flag,
                salesrep_flag,
                ga_flag,
                salesrep_id,
                ga_id,
                source,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                acct_for_pretax_flag,
                permit_partcp_eoy,
                ee_exclude_plan_flag,
                coincident_next_flag,
                limit_cash_paid,
                min_service_req,
                exclude_seasonal_flag,
                fmla_leave,
                fmla_tax,
                fmla_under_cobra,
                fmla_return_leave,
                fmla_contribution,
                ee_rehire_plan,
                ee_reemploy_plan,
                er_partcp_elect,
                failure_plan_yr,
                plan_admin,
                admin_contact_type,
                admin_name,
                hsa_contrib,
                max_contrib_amt,
                matching_contrib,
                non_elect_contrib,
                percent_non_elect_amt,
                other_non_elect_amt,
                max_contrib_hsa,
                other_max_contrib,
                flex_credit_flag,
                flex_credit_cash,
                flex_cash_amt,
                er_contrib_flex,
                flex_contrib_amt,
                other_flex_amt,
                cash_out_amt,
                max_flex_cash_out,
                dollar_amt,
                other_max_cash_out,
                amt_distrib,
                min_age,
                min_contrib_hsa,
                when_partcp_eoy, /*Ticket#6876 */
                flex_credit_5000a_flag,     -- ticket 7863 rprabu
                flex_credits_er_contrib,     -- ticket 7863  rprabu
                fmla_flag,                     -- ticket 7863  rprabu
                employee_elections,               -- Start Added by Swamy for Ticket#11037
                include_participant_election,
                change_status_below_30,
                change_status_special_annual_enrollment,
                include_fmla_lang,                 -- Code addtion end by Swamy for Ticket#11037
                change_status_dependent_special_enrollment    -- Added by Swamy for Ticket#12131 22052024
            )
                (
                    select
                        eligibility_seq.nextval,
                        l_renewed_plan_id,
                        no_of_hrs_part_time,
                        no_of_hrs_seasonal,
                        no_of_hrs_current,
                        new_ee_month_servc,
                        collective_bargain_flag,
                        union_ee_join_flag,
                        plan_new_ee_join,
                        select_entry_date_flag,
                        min_age_req,
                        automatic_enroll,
                        revoke_elect_flag,
                        cease_covg_flag,
                        contrib_flag,
                        contrib_amt,
                        percent_contrib,
                        permit_cash_flag,
                        limit_cash_flag,
                        salesrep_flag,
                        ga_flag,
                        salesrep_id,
                        ga_id,
                        source,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        acct_for_pretax_flag,
                        permit_partcp_eoy,
                        ee_exclude_plan_flag,
                        coincident_next_flag,
                        limit_cash_paid,
                        min_service_req,
                        exclude_seasonal_flag,
                        fmla_leave,
                        fmla_tax,
                        fmla_under_cobra,
                        fmla_return_leave,
                        fmla_contribution,
                        ee_rehire_plan,
                        ee_reemploy_plan,
                        er_partcp_elect,
                        failure_plan_yr,
                        plan_admin,
                        admin_contact_type,
                        admin_name,
                        hsa_contrib,
                        max_contrib_amt,
                        matching_contrib,
                        non_elect_contrib,
                        percent_non_elect_amt,
                        other_non_elect_amt,
                        max_contrib_hsa,
                        other_max_contrib,
                        flex_credit_flag,
                        flex_credit_cash,
                        flex_cash_amt,
                        er_contrib_flex,
                        flex_contrib_amt,
                        other_flex_amt,
                        cash_out_amt,
                        max_flex_cash_out,
                        dollar_amt,
                        other_max_cash_out,
                        amt_distrib,
                        min_age,
                        min_contrib_hsa,
                        when_partcp_eoy, /*Ticket#6876 */
                        flex_credit_5000a_flag,     -- ticket 7863 rprabu
                        flex_credits_er_contrib,     -- ticket 7863  rprabu
                        fmla_flag,                   -- ticket 7863  rprabu
                        employee_elections,               -- Start Added by Swamy for Ticket#11037
                        include_participant_election,
                        change_status_below_30,
                        change_status_special_annual_enrollment,
                        include_fmla_lang,                 -- Code addtion end by Swamy for Ticket#11037
                        change_status_dependent_special_enrollment    -- Added by Swamy for Ticket#12131 22052024
                    from
                        custom_eligibility_req
                    where
                        entity_id = p_plan_id
                );

      /** benefit Codes **/
            pc_log.log_error('In Populate renewal..AR Quote', 'Benefit Codes');
            insert into benefit_codes_stage (
                benefit_code_id,
                benefit_code_name,
                entity_id,
                entity_type,
                description,
                batch_number,
                creation_date,
                created_by
            )
                (
                    select
                        benefit_code_seq.nextval,
                        benefit_code_name,
                        l_renewed_plan_id,
                        'POP_PLAN_SETUP',
                        description,
                        p_batch_number,
                        sysdate,
                        p_user_id
                    from
                        benefit_codes
                    where
                        entity_id = p_plan_id
                );

   /* Create Contacts Broker data */
            select
                broker_id
            into l_cnt_contact
            from
                emp_overview_v
            where
                entrp_id = p_entrp_id;

     --For contacts which did not get craeted thru online enrollment
            if l_cnt_contact <> 0 then
                insert into contact_leads (
                    contact_id,
                    first_name,
                    entity_id,
                    entity_type,
                    ref_entity_type,
                    email,
                    contact_type,
                    user_id,
                    phone_num,
                    contact_fax,
                    account_type,
                    lic_number,
                    lic_number_flag
                )   -- Added by Swamy for Ticket#11691

                    select
                        contact_seq.nextval,
                        first_name || last_name,
                        pc_entrp.get_tax_id(p_entrp_id),
                        'ENTERPRISE',
                        'ENTERPRISE',
                        broker_email,
                        'BROKER',
                        p_user_id,
                        broker_phone,
                        null,
                        'POP',
                        broker_lic,
                        decode(
                            nvl(broker_lic, '*'),
                            '*',
                            'N',
                            'Y'
                        )   -- Added by Swamy for Ticket#11691
                    from
                        table ( pc_broker.get_broker_info(l_cnt_contact) );

            end if;

    /* GA Contact */
            select
                count(*)
            into l_cnt_ga
            from
                contact
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and entity_type = 'GA'
                and account_type = 'POP'
                and contact_id not in (
                    select
                        contact_id
                    from
                        contact_leads
                    where
                        account_type = 'POP'
                );

    --If we old conatcts for old ER's which are not in contact leads, we are doing an entry in leads table */
            if l_cnt_ga <> 0 then
                select
                    ga_lic
                into l_ga_lic
                from
                    table ( pc_broker.get_ga_info(p_entrp_id) );

                insert into contact_leads (
                    contact_id,
                    first_name,
                    entity_id,
                    entity_type,
                    ref_entity_type,
                    email,
                    contact_type,
                    user_id,
                    phone_num,
                    contact_fax,
                    account_type,
                    lic_number,
                    lic_number_flag
                )   -- Added by Swamy for Ticket#11691
                    select
                        contact_seq.nextval,
                        first_name || last_name,
                        pc_entrp.get_tax_id(p_entrp_id),
                        'ENTERPRISE',
                        'ENTERPRISE' /*Helps distinguish between recorsd already present and onez that are newly craeted during renewals */
                        ,
                        email,
                        'GA',
                        p_user_id,
                        phone,
                        null,
                        'POP',
                        l_ga_lic,
                        decode(
                            nvl(l_ga_lic, '*'),
                            '*',
                            'N',
                            'Y'
                        )   -- Added by Swamy for Ticket#11691
                    from
                        table ( pc_contact.get_contact_info(
                            pc_entrp.get_tax_id(p_entrp_id),
                            'GA'
                        ) );

            end if;

        end if; /* Cnt loop */

 --Some fields are only in staging table and are tracked in PDF. Those also need to be repopulated for renewal records.
        select
            count(*)
        into l_cnt
        from
            online_compliance_staging
        where
                entrp_id = p_entrp_id
            and source is null;

        pc_log.log_error('In Populate renewal..AR Quote l_cnt ', 'l_cnt'
                                                                 || l_cnt
                                                                 || ' p_entrp_id :='
                                                                 || p_entrp_id);
        if l_cnt > 0 then
            for x in (
                select
                    remittance_flag,
                    entity_name_desc,
                    send_invoice,
                    bank_name
                from
                    online_compliance_staging
                where
                        entrp_id = p_entrp_id
                    and source is null
            ) loop
                update online_compliance_staging
                set
                    remittance_flag = x.remittance_flag,
                    entity_name_desc = x.entity_name_desc,
                    send_invoice = x.send_invoice
                where
                        batch_number = p_batch_number
                    and entrp_id = p_entrp_id;

            end loop;
        end if;

        select
            count(*)
        into l_cnt
        from
            compliance_plan_staging
        where
                entity_id = p_entrp_id
            and batch_number <> p_batch_number;

        if l_cnt > 0 then
            for x in (
                select
                    ga_id,
                    ga_flag,
                    short_plan_yr_flag
                from
                    compliance_plan_staging
                where
                        entity_id = p_entrp_id
                    and batch_number <> p_batch_number
            ) loop
                update compliance_plan_staging
                set
                    ga_id = x.ga_id,
                    ga_flag = x.ga_flag,
                    short_plan_yr_flag = x.short_plan_yr_flag
                where
                        batch_number = p_batch_number
                    and entity_id = p_entrp_id;

            end loop;
        end if;

        begin
            l_batch_number := 0;
            select
                max(batch_number)
            into l_batch_number
            from
                plan_employer_contacts
            where
                    entity_id = p_plan_id
                and batch_number <> p_batch_number;

        exception
            when no_data_found then
                null;
        end;

        if
            nvl(l_cnt, 0) > 0
            and nvl(l_renewal_resubmit_flag, 'N') = 'N'
        then   -- NVL by jaggi for Ticket#10431
            insert into plan_employer_contacts_stage (
                plan_admin_name,
                contact_type,
                contact_name,
                phone_num,
                email,
                address1,
                address2,
                city,
                state,
                zip_code,
                plan_agent,
                description,
                agent_name,
                legal_agent_contact,
                legal_agent_phone,
                legal_agent_email,
                trust_fund,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                record_id,
                entity_id,
                batch_number,
                admin_type,
                trustee_name,
                trustee_contact_type,
                trustee_contact_name,
                trustee_contact_phone,
                trustee_contact_email,
                legal_agent_contact_type,
                governing_state
            )
                (
                    select
                        plan_admin_name,
                        contact_type,
                        contact_name,
                        phone_num,
                        email,
                        address1,
                        address2,
                        city,
                        state,
                        zip_code,
                        plan_agent,
                        description,
                        agent_name,
                        legal_agent_contact,
                        legal_agent_phone,
                        legal_agent_email,
                        trust_fund,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        sysdate,
                        record_id,
                        p_entrp_id,
                        p_batch_number,
                        admin_type,
                        trustee_name,
                        trustee_contact_type,
                        trustee_contact_name,
                        trustee_contact_phone,
                        trustee_contact_email,
                        legal_agent_contact_type,
                        governing_state
                    from
                        plan_employer_contacts
                    where
                            entity_id = p_plan_id
                        and batch_number = l_batch_number
                );

        end if;

    exception
        when others then
            pc_log.log_error('Populate renewal data..', sqlerrm);
    end populate_renewal_data;

-- Added by Joshi 5020. changes report for POP renewal.
    procedure pos_renewal_det_pop (
        p_acc_id in number default null
    ) is

        type rec_ben_pop is
            table of pop_rec;
        type rec_insur_name is
            table of insur_plan_rec;
        type rec_worksheet is record (
            work_book varchar2(4000)
        );
        type tbl_worksheet is
            table of rec_worksheet;
        type rec_benefit_code is
            table of benefit_code_rec;
        l_benefit_code_old    rec_benefit_code;
        l_benefit_code_new    rec_benefit_code;
        l_ben_plan_new        rec_ben_pop;
        l_rec_insur_name      rec_insur_name;
        l_worksheet           rec_worksheet;
        v_start               varchar2(1) := 'Y';
        v_old_data            varchar2(1);
        v_file_id             number;
        v_work_sheet          varchar2(4000);
        v_file_name           varchar2(4000);
        r                     number := 0;
        v_plan_type           varchar2(100);
        v_ben_plan_name       varchar2(100);
        v_plan_start_date     varchar2(100);
        v_plan_end_date       varchar2(100);
        v_open_enr_start_date varchar2(100);
        v_open_enr_end_date   varchar2(100);
        v_effect_date         varchar2(100);
        v_status              varchar2(100);
        v_no_of_eligible      varchar2(100);
        v_entity_type         varchar2(100);
        v_affiliated_er       varchar2(100);
        v_controlled_group    varchar2(100);
        v_ben_plan_number     varchar2(100);
        v_plan_include        varchar2(100);
        v_clm_lang_in_spd     varchar2(100);
        v_grandfathered       varchar2(100);
        v_form55_opted        varchar2(100);
        v_broker_added        varchar2(100);
        v_ga_added            varchar2(100);
        v_html_msg            varchar2(4000);
        v_broker_contact      varchar2(4000);
        v_broker_contact_new  varchar2(4000);
        v_ga_contact          varchar2(4000);
        v_email               varchar2(4000);
        v_address_change      number := 0;
        v_ben_code_change     number := 0;
        v_special_instruction number := 0;
        v_pop_plan_type       varchar2(255);
        v_min_age_req_old     varchar2(1);
        v_min_age_req_new     varchar2(1);
        l_line_no             number := 0;
        l_description         varchar2(100);
        l_eligibility         varchar2(100);
        l_er_cont_pref        number;
        l_ee_cont_pref        number;
        l_renew_option        varchar2(1);
        l_previous_option     varchar2(1);
    begin
        dbms_output.put_line('START ERISA CHANGE');
        select
            *
        bulk collect
        into l_ben_plan_new
        from
            (
                select
                    a.entrp_id,
                    bp.ben_plan_id,
                    bp.acc_id,
                    pc_lookups.get_meaning('RENEW', 'PLAN_TYPE_WRAP')        plan_type,
                    b.acc_num,
                    bp.ben_plan_name,
                    to_char(bp.plan_start_date, 'MM/DD/YYYY')                plan_start_date,
                    to_char(bp.plan_end_date, 'MM/DD/YYYY')                  plan_end_date,
                    to_char(bp.effective_date, 'MM/DD/YYYY')                 effective_date,
                    pc_lookups.get_meaning(bp.plan_type, 'POP_PLAN')         pop_plan_type  /*Ticket#6702 */,
                    pc_lookups.get_meaning(bp.status, 'BEN_PLAN_STATUS')     status,
                    a.no_of_eligible  --ES.NO_OF_ELIGIBLE
                    ,
                    pc_lookups.get_meaning(a.entity_type, 'ENTITY_TYPE')     entity_type,
                    null                                                     old_entity_type,
                    pc_lookups.get_meaning(pop_stg.affliated_flag, 'YES_NO') affiliated_er,
                    pc_lookups.get_meaning(pop_stg.cntrl_grp_flag, 'YES_NO') controlled_group,
                    bp.ben_plan_number,
                    pc_broker.get_broker_name(b.broker_id)                   broker_added,
                    pc_sales_team.get_general_agent_name(b.ga_id)            ga_added,
                    bpr.ben_plan_id                                          old_plan_id
                from
                    enterprise                a,
                    account                   b,
                    ben_plan_enrollment_setup bp,
                    ben_plan_renewals         bpr,
                    online_compliance_staging pop_stg
                where
                        b.acc_id = nvl(p_acc_id, b.acc_id)
                    and a.entrp_id = b.entrp_id
                    and bpr.renewed_plan_id = bp.ben_plan_id
                    and bp.acc_id = b.acc_id
                    and a.entrp_id = pop_stg.entrp_id (+)
                    and pop_stg.source = 'RENEWAL'
                    and trunc(bpr.creation_date) >= trunc(sysdate) - 1
            );

        dbms_output.put_line('BEFORE LOOP');
        for i in 1..l_ben_plan_new.count loop
            if v_start = 'Y' then
                dbms_output.put_line('EXCEL SETUP');
                l_line_no := 0;
                v_file_id := pc_file_upload.insert_file_seq('DAILY_RENEWAL_BEN_PLAN_POP');
                v_file_name := 'POP_Renewal_Changes_Report_'
                               || v_file_id
                               || '_'
                               || to_char(sysdate, 'YYYYMMDDHH24MISS')
                               || '.xls';

              --GEN_XL_XML.CREATE_EXCEL( 'DAILY_RENEWAL_POP_ERISA',V_FILE_NAME) ;
                gen_xl_xml.create_excel('MAILER_DIR', v_file_name);
                gen_xl_xml.create_style('BEN_PLAN_HEADER', 'Calibri', 'Black', 10,
                                        p_bold => true);
                gen_xl_xml.create_style('BEN_PLAN_HEADER_BEN_PLAN', 'Calibri', 'Red', 10,
                                        p_bold => true);
                gen_xl_xml.create_style('BEN_PLAN_HEADER_BEN_PLAN1', 'Calibri', 'Blue', 10,
                                        p_bold => true);
                gen_xl_xml.create_style('BEN_PLAN_COLUMN', 'Calibri', 'Black', 9);
                gen_xl_xml.create_style('BEN_PLAN_COLUMN_CHG', 'Calibri', 'Green', 9,
                                        p_backcolor => 'Yellow');
                for ik in 1..l_ben_plan_new.count loop
                    l_worksheet.work_book := l_ben_plan_new(ik).acc_num
                                             || '-'
                                             || l_ben_plan_new(ik).plan_type;

                    gen_xl_xml.create_worksheet(l_worksheet.work_book);
                    v_work_sheet := l_worksheet.work_book;
                end loop;

            end if;

            dbms_output.put_line('VARIABLE SETUP');
            v_old_data := 'N';
            v_start := 'N';
            r := 1;
            v_work_sheet := l_ben_plan_new(i).acc_num
                            || '-'
                            || l_ben_plan_new(i).plan_type;

            v_plan_type := null;
            v_ben_plan_name := null;
            v_plan_start_date := null;
            v_plan_end_date := null;
            v_open_enr_start_date := null;
            v_open_enr_end_date := null;
            v_effect_date := null;
            v_pop_plan_type := null;
            v_status := null;
            v_no_of_eligible := null;
            v_entity_type := l_ben_plan_new(i).old_entity_type;
            v_affiliated_er := null;
            v_controlled_group := null;
            v_ben_plan_number := null;
            v_plan_include := null;
            v_clm_lang_in_spd := null;
            v_grandfathered := null;
            v_form55_opted := null;
            v_broker_added := null;
            v_ga_added := null;
            v_broker_contact := null;
            v_ga_contact := null;
            v_address_change := 0;
            v_ben_code_change := 0;
            v_special_instruction := 0;
            for j in (
                select -- WM_CONCAT(FIRST_NAME) FIRST_NAME  -- Wm_Concat function replaced by listagg by RPRABU on 17/10/2017
                    listagg(first_name, ',') within group(
                    order by
                        first_name
                    ) first_name
                from
                    (
                        select distinct
                            first_name first_name
                        from
                            contact_leads
                        where
                                contact_type = 'BROKER'
                            and entity_id = pc_entrp.get_tax_id(l_ben_plan_new(i).entrp_id)
                            and entity_type = 'ENTERPRISE'
                            and account_type = 'POP'
                            and ref_entity_type in ( 'BEN_PLAN_RENEWALS', 'ONLINE_ENROLLMENT' )
                            and lic_number is null
                    )
            ) loop
                l_ben_plan_new(i).broker_added := 'Y';
                v_broker_contact_new := j.first_name;
                if v_broker_contact_new is null then
                    l_ben_plan_new(i).broker_added := 'N';
                else
                    l_ben_plan_new(i).broker_added := 'Y';
                end if;

            end loop;

             /* GA not required for POP
             FOR J IN (SELECT FIRST_NAME
                         FROM CONTACT_LEADS
                             WHERE ENTITY_TYPE = 'BROKER'
                               and  ENTITY_ID = PC_ENTRP.GET_TAX_ID(L_BEN_PLAN_NEW(I).ENTRP_ID)
                               AND ACCOUNT_TYPE = 'GA'
                               AND REF_ENTITY_TYPE = 'BEN_PLAN_RENEWALS')  LOOP
                 L_BEN_PLAN_NEW(I).GA_ADDED := J.FIRST_NAME;
             END LOOP;
            */

            pc_log.log_error('Old Ben ID..',
                             l_ben_plan_new(i).old_ben_plan_id);
            for ak in (
                select
                    pc_lookups.get_meaning('NEW', 'PLAN_TYPE_WRAP')      plan_type,
                    b.acc_num,
                    bp.ben_plan_name,
                    to_char(bp.plan_start_date, 'MM/DD/YYYY')            plan_start_date,
                    to_char(bp.plan_end_date, 'MM/DD/YYYY')              plan_end_date,
                    to_char(bp.effective_date, 'MM/DD/YYYY')             effective_date,
                    bp.ben_plan_name                                     pop_plan_type,
                    pc_lookups.get_meaning(bp.status, 'BEN_PLAN_STATUS') status,
                    bp.ben_plan_number,
                    pc_lookups.get_meaning(a.entity_type, 'ENTITY_TYPE') entity_type,
                    pc_lookups.get_meaning(bp.clm_lang_in_spd, 'YES_NO') clm_lang_in_spd,
                    pc_lookups.get_meaning(bp.grandfathered, 'YES_NO')   grandfathered,
                    pc_lookups.get_meaning(bp.is_5500, 'YES_NO')         form55_opted,
                    pc_broker.get_broker_name(b.broker_id)               broker_added ---NVL(PC_BROKER.GET_BROKER_NAME(B.BROKER_ID),'No') BROKER_ADDED
                    ,
                    pc_sales_team.get_general_agent_name(b.ga_id)        ga_added --NVL(PC_SALES_TEAM.GET_GENERAL_AGENT_NAME(B.GA_ID),'No') GA_ADDED
                from
                    enterprise                a,
                    account                   b,
                    ben_plan_enrollment_setup bp
                where
                        a.entrp_id = b.entrp_id
                    and b.acc_id = bp.acc_id
                    and bp.ben_plan_id = l_ben_plan_new(i).old_ben_plan_id
            ) loop
                                                  --AND BEN_PLAN_NUMBER = L_BEN_PLAN_NEW(I).BEN_PLAN_NUMBER)) LOOP
                v_old_data := 'Y';
                v_plan_type := ak.plan_type;
                v_ben_plan_name := ak.ben_plan_name;
                v_plan_start_date := ak.plan_start_date;
                v_plan_end_date := ak.plan_end_date;
                v_effect_date := ak.effective_date;
                v_pop_plan_type := ak.pop_plan_type;
                v_status := ak.status;
            --    V_ENTITY_TYPE          :=  AK.ENTITY_TYPE;
                v_clm_lang_in_spd := ak.clm_lang_in_spd;
                v_grandfathered := ak.grandfathered;
                v_form55_opted := ak.form55_opted;
                v_broker_added := ak.broker_added;
                v_ga_added := ak.ga_added;
                v_ben_plan_number := ak.ben_plan_number;
                for xx in (
                    select
                        no_of_eligible,
                        pc_lookups.get_meaning(
                            nvl(affliated_flag, 'N'),
                            'YES_NO'
                        ) affiliated_er_old,
                        pc_lookups.get_meaning(
                            nvl(cntrl_grp_flag, 'N'),
                            'YES_NO'
                        ) controlled_group_old
                    from
                        online_compliance_staging
                    where
                            entrp_id = l_ben_plan_new(i).entrp_id
                        and source = 'RENEWAL'
                ) loop
                    v_no_of_eligible := xx.no_of_eligible;
                    v_affiliated_er := xx.affiliated_er_old;
                    v_controlled_group := xx.controlled_group_old;
                end loop;

            end loop;

            dbms_output.put_line('INNER FOR LOOP END');
            v_broker_added := 'N';
            for j in (
                select -- WM_CONCAT(FIRST_NAME) FIRST_NAME  -- Wm_Concat function replaced by listagg by RPRABU on 17/10/2017
                    listagg(first_name, ',') within group(
                    order by
                        first_name
                    ) first_name
                from
                    (
                        select distinct
                            first_name first_name
                        from
                            contact_leads
                        where
                                contact_type = 'BROKER'
                            and entity_id = pc_entrp.get_tax_id(l_ben_plan_new(i).entrp_id)
                            and entity_type = 'ENTERPRISE'
                            and account_type = 'POP'
                            and ref_entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                    )
            ) loop
                v_broker_contact := j.first_name;
                if v_broker_contact is null then
                    v_broker_added := 'N';
                else
                    v_broker_contact := 'Y';
                end if;

            end loop;
        /*
           FOR J IN ( SELECT --WM_CONCAT(FIRST_NAME) FIRST_NAME FROM
                                     LISTAGG(FIRST_NAME, ',') WITHIN GROUP (ORDER BY FIRST_NAME) FIRST_NAME
                     FROM
                        (SELECT DISTINCT FIRST_NAME FIRST_NAME
                           FROM CONTACT_LEADS
                          WHERE CONTACT_TYPE = 'GA'
                             AND REF_ENTITY_ID    = L_BEN_PLAN_NEW(I).BEN_PLAN_ID
                             AND REF_ENTITY_TYPE  = 'BEN_PLAN_ENROLLMENT_SETUP')) LOOP
               V_GA_CONTACT := J.FIRST_NAME;
           END LOOP;
           */
            l_line_no := 0;
            gen_xl_xml.set_column_width(1, 150, v_work_sheet);
           --Plan Setup Work sheet Header
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Employer Name(Account Number)', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_char(l_line_no,
                                       r + 1,
                                       v_work_sheet,
                                       pc_entrp.get_entrp_name(l_ben_plan_new(i).entrp_id)
                                       || '('
                                       || l_ben_plan_new(i).acc_num
                                       || ')',
                                       'BEN_PLAN_COLUMN');

            gen_xl_xml.write_cell_null(l_line_no, r + 2, v_work_sheet, 'BEN_PLAN_HEADER');
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_null(l_line_no, r, v_work_sheet, 'BEN_PLAN_HEADER');
            dbms_output.put_line('1');
            if v_old_data = 'N' then
              --GEN_XL_XML.WRITE_CELL_CHAR( 2,  R+1, V_WORK_SHEET , 'Renewed Plan',  'BEN_PLAN_HEADER_BEN_PLAN1' );
                gen_xl_xml.write_cell_null(l_line_no, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            else
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, 'Renewed Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
                gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, 'Previous Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
            end if;

            dbms_output.put_line('2');
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(l_line_no, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Name', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).ben_plan_name,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).ben_plan_name,
                       'S') != nvl(v_ben_plan_name, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ben_plan_name,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_ben_plan_name, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ben_plan_name,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_ben_plan_name, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('4');
           /*
           SELECT COUNT(*) INTO V_ADDRESS_CHANGE
                     FROM NOTES
                      WHERE ENTITY_ID = L_BEN_PLAN_NEW(I).entrp_id
                      AND   ENTITY_TYPE = 'ENTERPRISE'
                      AND   NOTE_ACTION = 'ADDRESS_CHANGE'
                      AND   CREATION_DATE >TRUNC(SYSDATE)-1;
           GEN_XL_XML.WRITE_CELL_CHAR( l_line_no,  R,   V_WORK_SHEET , 'Company Address', 'BEN_PLAN_HEADER' );
           GEN_XL_XML.WRITE_CELL_CHAR( l_line_no,  R+1, V_WORK_SHEET , CASE WHEN v_address_change > 0 THEN 'Yes' ELSE 'No' END, 'BEN_PLAN_COLUMN' );

        */

            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Start Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).plan_start_date,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).plan_start_date,
                       'S') != nvl(v_plan_start_date, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_start_date,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_start_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_start_date,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_start_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan End Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).plan_end_date,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).plan_end_date,
                       'S') != nvl(v_plan_end_date, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_end_date,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).plan_end_date,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('5');
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Effective Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).effective_date,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).effective_date,
                       'S') != nvl(v_effect_date, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).effective_date,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_effect_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).effective_date,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_effect_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

        -- pop plan type
            l_line_no := l_line_no + 1;
            dbms_output.put_line('5');
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'POP PLAN Type', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).pop_plan_type,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).pop_plan_type,
                       'S') != nvl(v_pop_plan_type, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).pop_plan_type,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_pop_plan_type, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).pop_plan_type,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_pop_plan_type, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Status', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).status,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).status,
                       'S') != nvl(v_status, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).status,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_status, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).status,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_status, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('6');
            pc_log.log_error('Before New..', 'Writing Data3');
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'No of eligible employees', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(l_line_no,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).no_of_eligible,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).no_of_eligible,
                       -1) != nvl(v_no_of_eligible, -1) then
                    gen_xl_xml.write_cell_num(l_line_no,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).no_of_eligible,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(l_line_no, r + 2, v_work_sheet, v_no_of_eligible, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(l_line_no,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).no_of_eligible,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(l_line_no, r + 2, v_work_sheet, v_no_of_eligible, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Type of Entity', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).entity_type,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).entity_type,
                       'S') != nvl(l_ben_plan_new(i).entity_type,
                                   'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).entity_type,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 2,
                                               v_work_sheet,
                                               l_ben_plan_new(i).entity_type,
                                               'BEN_PLAN_COLUMN_CHG');

                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).entity_type,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 2,
                                               v_work_sheet,
                                               l_ben_plan_new(i).entity_type,
                                               'BEN_PLAN_COLUMN');

                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Affilitated Employers', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).affiliated_er,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).affiliated_er,
                       'S') != nvl(v_affiliated_er, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).affiliated_er,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_affiliated_er, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).affiliated_er,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_affiliated_er, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('7');
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Company Owned by another company', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).controlled_group,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).controlled_group,
                       'S') != nvl(v_controlled_group, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).controlled_group,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_controlled_group, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).controlled_group,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_controlled_group, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('8');
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Number', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(l_line_no,
                                          r + 1,
                                          v_work_sheet,
                                          l_ben_plan_new(i).ben_plan_number,
                                          'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).ben_plan_number,
                       -1) != nvl(v_ben_plan_number, -1) then
                    gen_xl_xml.write_cell_num(l_line_no,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).ben_plan_number,
                                              'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_num(l_line_no, r + 2, v_work_sheet, v_ben_plan_number, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(l_line_no,
                                              r + 1,
                                              v_work_sheet,
                                              l_ben_plan_new(i).ben_plan_number,
                                              'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_num(l_line_no, r + 2, v_work_sheet, v_ben_plan_number, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            dbms_output.put_line('9');

            -- populate insurance plan options.
            select
                *
            bulk collect
            into l_rec_insur_name
            from
                (
                    select
                        a.description,
                        nvl(a.ref_exists, 'N') renewal_plan,
                        nvl(b.ref_exists, 'N') previous_plan
                    from
                        (
                            select
                                case
                                    when t2.benefit_code_name = '5K' then
                                        t1.description
                                        || '('
                                        || t2.description
                                        || ')'
                                    else
                                        t1.description
                                end as description,
                                case
                                    when t2.benefit_code_name is null then
                                        'N'
                                    else
                                        'Y'
                                end as ref_exists
                            from
                                lookups t1
                                left join (
                                    select
                                        benefit_code_name,
                                        description
                                    from
                                        benefit_codes
                                    where
                                        entity_id = l_ben_plan_new(i).ben_plan_id
                                )       t2 on t1.lookup_code = t2.benefit_code_name
                            where
                                t1.lookup_name = 'POP_ELIGIBILITY'
                        ) a
                        left outer join (
                            select
                                case
                                    when t2.benefit_code_name = '5K' then
                                        t1.description
                                        || '('
                                        || t2.description
                                        || ')'
                                    else
                                        t1.description
                                end as description,
                                case
                                    when t2.benefit_code_name is null then
                                        'N'
                                    else
                                        'Y'
                                end as ref_exists
                            from
                                lookups t1
                                left join (
                                    select
                                        benefit_code_name,
                                        description
                                    from
                                        benefit_codes
                                    where
                                        entity_id = l_ben_plan_new(i).old_ben_plan_id
                                )       t2 on t1.lookup_code = t2.benefit_code_name
                            where
                                t1.lookup_name = 'POP_ELIGIBILITY'
                        ) b on a.description = b.description
                );

            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Insurance plan', 'BEN_PLAN_HEADER_BEN_PLAN');
          -- GEN_XL_XML.WRITE_CELL_CHAR( l_line_no,  R+1, V_WORK_SHEET , CASE WHEN V_BEN_CODE_CHANGE > 0 THEN 'Yes' ELSE 'No' END, 'BEN_PLAN_COLUMN' );

            dbms_output.put_line('10');
            l_line_no := l_line_no + 1;

          -- insurance plans option.
            for x in 1..l_rec_insur_name.count loop
                gen_xl_xml.write_cell_char(l_line_no,
                                           r,
                                           v_work_sheet,
                                           l_rec_insur_name(x).plan_name,
                                           'BEN_PLAN_HEADER');

                dbms_output.put_line('L_REC_INSUR_NAME(x).PLAN_NAME' || l_rec_insur_name(x).plan_name);
                l_renew_option := l_rec_insur_name(x).renewal_plan;
                l_previous_option := l_rec_insur_name(x).previous_plan;
                if l_renew_option != l_previous_option then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, l_renew_option, 'BEN_PLAN_COLUMN_CHG');
                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, l_previous_option, 'BEN_PLAN_COLUMN_CHG');
                    dbms_output.put_line('L_REC_INSUR_NAME(x).RENEWAL_PLAN ' || l_renew_option);
                    dbms_output.put_line('L_REC_INSUR_NAME(x).PREVIOUS_PLAN ' || l_previous_option);
                else
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, l_renew_option, 'BEN_PLAN_COLUMN');
                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, l_previous_option, 'BEN_PLAN_COLUMN');
                    dbms_output.put_line('L_REC_INSUR_NAME(x).RENEWAL_PLAN ' || l_renew_option);
                    dbms_output.put_line('L_REC_INSUR_NAME(x).PREVIOUS_PLAN ' || l_previous_option);
                end if;

                l_line_no := l_line_no + 1;
                dbms_output.put_line(l_line_no);
            end loop;

           -- Minimum age requirement.
            --l_line_no := l_line_no+1;
            for x in (
                select
                    nvl(min_age_req, 'N') min_age_req_old
                from
                    custom_eligibility_req
                where
                    entity_id = l_ben_plan_new(i).old_ben_plan_id
            ) loop
                v_min_age_req_old := x.min_age_req_old;
            end loop;

            for x in (
                select
                    nvl(min_age_req, 'N') min_age_req_new
                from
                    custom_eligibility_req
                where
                    entity_id = l_ben_plan_new(i).ben_plan_id
            ) loop
                v_min_age_req_new := x.min_age_req_new;
            end loop;

            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Is there a minimum age requirement to participate? ', 'BEN_PLAN_HEADER'
            );
            if v_min_age_req_new != v_min_age_req_old then
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_min_age_req_new, 'BEN_PLAN_COLUMN_CHG');
                gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_min_age_req_old, 'BEN_PLAN_COLUMN_CHG');
            else
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_min_age_req_new, 'BEN_PLAN_COLUMN');
                gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_min_age_req_old, 'BEN_PLAN_COLUMN');
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Broker Added ?', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).broker_added,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).broker_added,
                       'S') != nvl(v_broker_added, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).broker_added,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_broker_added, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).broker_added,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_broker_added, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            dbms_output.put_line('11');
            /*
            l_line_no := l_line_no+1;
           GEN_XL_XML.WRITE_CELL_CHAR( l_line_no, R,   V_WORK_SHEET , 'General Agent Added ?', 'BEN_PLAN_HEADER' );
           IF V_OLD_DATA = 'N' THEN
                 GEN_XL_XML.WRITE_CELL_CHAR( l_line_no, R+1, V_WORK_SHEET , L_BEN_PLAN_NEW(I).GA_ADDED , 'BEN_PLAN_COLUMN' );
           ELSE
              IF NVL(L_BEN_PLAN_NEW(I).GA_ADDED ,'S') != NVL(V_GA_ADDED ,'S') THEN
                 GEN_XL_XML.WRITE_CELL_CHAR( l_line_no,  R+1, V_WORK_SHEET , L_BEN_PLAN_NEW(I).GA_ADDED , 'BEN_PLAN_COLUMN_CHG' );
                 GEN_XL_XML.WRITE_CELL_CHAR( l_line_no,  R+2, V_WORK_SHEET , V_GA_ADDED , 'BEN_PLAN_COLUMN_CHG' );
              ELSE
                 GEN_XL_XML.WRITE_CELL_CHAR( l_line_no,  R+1, V_WORK_SHEET , L_BEN_PLAN_NEW(I).GA_ADDED , 'BEN_PLAN_COLUMN' );
                 GEN_XL_XML.WRITE_CELL_CHAR( l_line_no,  R+2, V_WORK_SHEET , V_GA_ADDED , 'BEN_PLAN_COLUMN' );
              END IF;
           END IF;
           l_line_no := l_line_no+1;
           */

            dbms_output.put_line('12');
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Broker Contact', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no,
                                       r + 1,
                                       v_work_sheet,
                                       replace(
                                replace(v_broker_contact_new, '>', ''),
                                '<',
                                ''
                            ),
                                       'BEN_PLAN_COLUMN');

            gen_xl_xml.write_cell_char(l_line_no,
                                       r + 2,
                                       v_work_sheet,
                                       replace(
                                replace(v_broker_contact, '>', ''),
                                '<',
                                ''
                            ),
                                       'BEN_PLAN_COLUMN');
           /*
           l_line_no := l_line_no+1; --Added by Puja
           GEN_XL_XML.WRITE_CELL_CHAR( l_line_no, R,   V_WORK_SHEET , 'GA Contact', 'BEN_PLAN_HEADER' );
           GEN_XL_XML.WRITE_CELL_CHAR( l_line_no, R+1, V_WORK_SHEET , REPLACE(REPLACE(V_GA_CONTACT,'>',''),'<','') , 'BEN_PLAN_COLUMN' );
           DBMS_OUTPUT.PUT_LINE('13');
            */
            dbms_output.put_line('Ben ID OLD' || l_ben_plan_new(i).old_ben_plan_id);
            pc_log.log_error('OLD BEN ID..',
                             l_ben_plan_new(i).old_ben_plan_id);
            pc_log.log_error('NEWBEN ID..',
                             l_ben_plan_new(i).ben_plan_id);

            /*
            SELECT COUNT(*)
            INTO V_SPEcIAL_INSTRUCTION
            FROM NOTES
              WHERE ENTITY_ID =  L_BEN_PLAN_NEW(I).ben_plan_id
              AND   ENTITY_TYPE = 'BEN_PLAN_ENROLLMENT_SETUP'
              AND   NOTE_ACTION = 'SPECIAL_INSTRUCTIONS'
              AND   CREATION_DATE >TRUNC(SYSDATE)-1;
            l_line_no := l_line_no+1;
            GEN_XL_XML.WRITE_CELL_CHAR( l_line_no, R,   V_WORK_SHEET , 'Special instructions', 'BEN_PLAN_HEADER' );
            GEN_XL_XML.WRITE_CELL_CHAR( l_line_no, R+1, V_WORK_SHEET ,CASE WHEN V_SPEcIAL_INSTRUCTION > 0 THEN 'Yes' ELSE 'No' END , 'BEN_PLAN_COLUMN' );
            */
        end loop;

        if l_ben_plan_new.count > 0 then
            gen_xl_xml.close_file;
        end if;
        dbms_output.put_line('User' || user);
        if file_exists(v_file_name, 'MAILER_DIR') = 'TRUE' then
            v_html_msg := '<html><body><br>
                  <p>Daily POP Renewal Changes Report for the Date '
                          || to_char(sysdate, 'MM/DD/YYYY')
                          || ' </p> <br> <br>
                   </body></html>';
            if user = 'SAM' then
                v_email := 'compliance@sterlingadministration.com'
                           || ',dan.tidball@sterlingadministration.com,DL_Sales@sterlingadministration.com'
                           || ',sarah.soman@sterlingadministration.com,IT-Team@sterlingadministration.com'
                           || ',VHSTeam@sterlingadministration.com';
            else
                v_email := 'IT-team@sterlingadministration.com';
                 --V_email :=  'puja.ghosh@sterlingadministration.com';

            end if;

            dbms_output.put_line('User befor Email' || user);

               --  After upgrade oracle@sterlingadministration.com does not work
            mail_utility.send_file_in_emails(
                p_from_email   => 'oracle@sterlinghsa.com',
                p_to_email     => v_email,
                p_file_name    => v_file_name,
                p_sql          => null,
                p_html_message => v_html_msg,
                p_report_title => 'Daily POP Renewal Changes Report for the Date ' || to_char(sysdate, 'MM/DD/YYYY')
            );

        end if;

        dbms_output.put_line('User After Email' || user);
    exception
        when no_data_found then
            dbms_output.put_line('ERROR '
                                 || ' '
                                 || sqlerrm
                                 || ' '
                                 || sqlcode);
        when others then
            dbms_output.put_line('ERROR '
                                 || ' '
                                 || sqlerrm
                                 || ' '
                                 || sqlcode);
    end pos_renewal_det_pop;

     -------------- 8135 form 5500 06/11/2019
    procedure pos_renewal_det_form_5500 (
        p_acc_id in number default null
    ) is

        type rec_ben_plan_setup is
            table of ben_plan_enrollment_setup%rowtype;
        type rec_ben_plan_renewal is
            table of ben_plan_renewals%rowtype;
        type rec_worksheet is record (
            work_book varchar2(4000)
        );
        type tbl_worksheet is
            table of rec_worksheet;
        type rec_benefit_code is
            table of benefit_code_form_5500_rec;
        l_benefit_code_old            rec_benefit_code;
        l_benefit_code_new            rec_benefit_code;
        l_ben_plan_new                rec_ben_plan_setup;
        l_ben_plan_renew_new          rec_ben_plan_renewal;
        l_worksheet                   rec_worksheet;
        v_start                       varchar2(1) := 'Y';
        v_old_data                    varchar2(1);
        v_file_id                     number;
        v_funding_options             varchar2(4000);
        v_funding_options_old         varchar2(4000);
        v_work_sheet                  varchar2(4000);
        v_file_name                   varchar2(4000);
        r                             number := 0;
        v_plan_type                   varchar2(100);
        v_company_address_new         varchar2(100);
        v_company_address             varchar2(100);
        v_no_of_eligible              number := 0;
        v_no_of_eligible_new          number := 0;
        v_retired_sep_ben             number := 0;
        v_retired_sep_fut_ben         number := 0;
        v_active_participant          number := 0;
        v_last_day_active_participant number := 0;
        v_enrd_emp_1st_day_nxt_pln_yr number := 0;
        v_active_participant_new      number := 0;
        v_retired_sep_ben_new         number := 0;
        v_retired_sep_fut_ben_new     number := 0;
        v_late_report_new             varchar2(100);
        v_late_report_old             varchar2(100);
        v_last_day_active_partici_new number := 0;
        v_emp_1st_day_nxt_pln_yr_new  number := 0;
        v_enrollment_detail_id_new    number := 0;
        v_special_instruction         varchar2(300); --8135
        v_special_instruction_old     varchar2(300); --8135
        v_ben_plan_name               varchar2(100);
        v_ben_plan_id                 number := 0;
        v_plan_notice_id_new          varchar2(100);
        v_is_collective_plan_new      varchar2(10);
        v_is_collective_plan_old      varchar2(10);
        v_plan_notice_id_old          varchar2(100);
        v_ben_plan_number             varchar2(100);
        v_plan_type_new               varchar2(100);
        v_plan_start_date             varchar2(100);
        v_plan_end_date               varchar2(100);
        v_open_enr_start_date         varchar2(100);
        v_open_enr_end_date           varchar2(100);
        v_effect_date                 varchar2(100);
        v_status                      varchar2(100);
        v_fiscal_end_date             varchar2(100);
        v_takeover                    varchar2(100);
        v_orig_eff_date               varchar2(100);
        v_amend_date                  varchar2(100);
        v_plan_docs_flag              varchar2(100);
        v_non_discrm_flag             varchar2(100);
        v_min_election                number;
        v_max_election                number;
        v_payroll_contrib             number;
        v_rollover                    varchar2(100);
        v_new_hire_contrib            varchar2(100);
        v_effect_end_date             varchar2(100);
        v_term_req_date               varchar2(100);
        v_term_elig                   varchar2(100);
        v_runout_period_days          number;
        v_runout_period_term          varchar2(100);
        v_grace_period                number;
        v_tran_period                 varchar2(100);
        v_tran_limit                  varchar2(100);
        v_iias_enable                 varchar2(100);
        v_claim_reimb_by              varchar2(100);
        v_reimb_start_date            varchar2(100);
        v_reimb_end_date              varchar2(100);
        v_allow_subst                 varchar2(100);
        v_note                        varchar2(4000);
        v_html_msg                    varchar2(4000);
        v_email                       varchar2(4000);
        v_count_other_fsa             number;
        v_start_date_old              varchar2(100);
        v_end_date_old                varchar2(100);
        v_entrp_id                    number;
        v_acc_id                      number;
        l_line_no                     number(6) := 0;
        v_ben_code_change             number := 0;
        v_ben_code_change_old         number := 0;
        v_ga_contact                  varchar2(100);
        v_broker_contact              varchar2(100);
        v_ga_contact_new              varchar2(100);
        v_broker_contact_new          varchar2(100);
        v_broker_added_old            varchar2(100);
        v_broker_added_new            varchar2(100);
        v_ga_added_old                varchar2(100);
        v_ga_added_new                varchar2(100);
        v_collective_plan_flag        varchar2(10);
        v_plan_funding_code           varchar2(300);
        v_plan_benefit_code           varchar2(300);
        v_emp_plan_sponsor_name_old   varchar2(100);
        v_emp_plan_admin_name_old     varchar2(100);
        v_annual_report_phone_no_old  varchar2(100);
        v_filing_old                  varchar2(100);
        v_erisa_wrap_flag_old         varchar2(100);
        v_collective_plan_flag_old    varchar2(100);
        v_plan_fund_code_old          varchar2(100);
        v_plan_benefit_code_old       varchar2(100);
        v_total_no_ee_old             number;
        v_is_coll_plan_old            varchar2(1);
        v_admin_sameas_sponsor_old    varchar2(5);
        v_sponsor_business_code_old   varchar2(100);
        v_next_yr_plan_start_date     varchar2(100);
        v_next_yr_plan_end_date       varchar2(100);
        v_next_yr_plan_start_date_old varchar2(100);
        v_next_yr_plan_end_date_old   varchar2(100);
    begin
        select
            *
        bulk collect
        into l_ben_plan_new
        from
            (
                select
                    *
                from
                    ben_plan_enrollment_setup a
                where
                    entrp_id is not null
                    and status = 'A'
                    and ( product_type = 'FORM_5500'
                          or plan_type in ( 'SNGL', 'SNGL_RENEW', 'MER', 'MER_RENEW', 'MERS_RENEW',
                                            'MERS' ) )
                    and exists (
                        select
                            1
                        from
                            ben_plan_enrollment_setup b
                        where
                                b.acc_id = a.acc_id
                            and status = 'P'
                            and trunc(creation_date) > trunc(sysdate) - 1
                                                                        and trunc(a.creation_date) < trunc(b.creation_date)
                    )    --- 8562 rprabu 09/12/2019
                    and not exists (
                        select
                            1
                        from
                            ben_plan_enrollment_setup b
                        where
                                b.ben_plan_id != a.ben_plan_id
                            and b.acc_id = a.acc_id
                            and nvl(b.ben_plan_number, '*') = nvl(a.ben_plan_number, '*')
                            and status = 'A'
                            and b.plan_type in ( 'SNGL', 'SNGL_RENEW', 'MER', 'MER_RENEW', 'MERS_RENEW',
                                                 'MERS' )
                    )
                union
                select
                    *
                from
                    ben_plan_enrollment_setup a
                where
                    entrp_id is not null
                    and status = 'A'
                    and ben_plan_id in (
                        select
                            ben_plan_id
                        from
                            ben_plan_renewals c
                        where
                                plan_type = 'FORM_5500'
                            and c.acc_id = a.acc_id
                            and trunc(creation_date) > trunc(sysdate) - 1
                    )
                    and ( product_type = 'FORM_5500'
                          or plan_type in ( 'SNGL', 'SNGL_RENEW', 'MER', 'MER_RENEW', 'MERS_RENEW',
                                            'MERS' ) )
                    and exists (
                        select
                            1
                        from
                            ben_plan_enrollment_setup b
                        where
                                b.ben_plan_id != a.ben_plan_id
                            and b.acc_id = a.acc_id
                            and nvl(b.ben_plan_number, '*') = nvl(a.ben_plan_number, '*')
                            and status = 'A'
                            and b.plan_type in ( 'SNGL', 'SNGL_RENEW', 'MER', 'MER_RENEW', 'MERS_RENEW',
                                                 'MERS' )
                    )
            );

  -- dbms_output.PUT_LINE('ERROR  1');

        if l_ben_plan_new.count > 0 then
            v_file_id := pc_file_upload.insert_file_seq('DAILY_RWL_BEN_PLAN_FORM_5500');
            v_file_name := 'FORM_5500_Renewal_Changes_Report_'
                           || v_file_id
                           || '_'
                           || to_char(sysdate, 'YYYYMMDDHH24MISS')
                           || '.xls';

            dbms_output.put_line('Strat file name' || v_file_name);
            gen_xl_xml.create_excel('MAILER_DIR', v_file_name);
            gen_xl_xml.create_style('BEN_PLAN_HEADER', 'Calibri', 'Black', 10,
                                    p_bold => true);
            gen_xl_xml.create_style('BEN_PLAN_HEADER_BEN_PLAN', 'Calibri', 'Red', 10,
                                    p_bold => true);
            gen_xl_xml.create_style('BEN_PLAN_HEADER_BEN_PLAN1', 'Calibri', 'Blue', 10,
                                    p_bold => true);
            gen_xl_xml.create_style('BEN_PLAN_COLUMN', 'Calibri', 'Black', 9);
            gen_xl_xml.create_style('BEN_PLAN_COLUMN_CHG', 'Calibri', 'Green', 9,
                                    p_backcolor => 'Yellow');
            for ik in 1..l_ben_plan_new.count loop

          --- BEN_PLAN_NUMBER added  nvl added if any null value for ben plan no Ticket #8526

           ---||'-'||to_char(Nvl(L_BEN_PLAN_NEW(IK).BEN_PLAN_NUMBER,IK))
                l_worksheet.work_book := pc_entrp.get_acc_num(l_ben_plan_new(ik).entrp_id)
                                         || '-'
                                         || l_ben_plan_new(ik).plan_type
                                         || '-'
                                         || l_ben_plan_new(ik).ben_plan_number;

                gen_xl_xml.create_worksheet(l_worksheet.work_book);
              --V_WORK_SHEET := L_WORKSHEET.WORK_BOOK;
            end loop;

        end if;
        -- dbms_output.PUT_LINE('ERROR  2');

        for i in 1..l_ben_plan_new.count loop
            v_old_data := 'N';
            v_start := 'N';
            v_funding_options := null;
            r := 1;
            v_work_sheet := pc_entrp.get_acc_num(l_ben_plan_new(i).entrp_id)
                            || '-'
                            || l_ben_plan_new(i).plan_type
                            || '-'
                            || l_ben_plan_new(i).ben_plan_number;

            v_plan_type := null;
            v_ben_plan_name := null;
            v_plan_start_date := null;
            v_plan_end_date := null;
            v_open_enr_start_date := null;
            v_open_enr_end_date := null;
            v_effect_date := null;
            v_status := null;
            v_fiscal_end_date := null;
            v_takeover := null;
            v_orig_eff_date := null;
            v_amend_date := null;
            v_plan_docs_flag := null;
            v_non_discrm_flag := null;
            v_min_election := null;
            v_max_election := null;
            v_payroll_contrib := null;
            v_funding_options_old := null;
            v_is_collective_plan_old := null;
            v_rollover := null;
            v_new_hire_contrib := null;
            v_effect_end_date := null;
            v_term_req_date := null;
            v_term_elig := null;
            v_runout_period_days := null;
            v_runout_period_term := null;
            v_grace_period := null;
            v_tran_period := null;
            v_tran_limit := null;
            v_iias_enable := null;
            v_claim_reimb_by := null;
            v_reimb_start_date := null;
            v_reimb_end_date := null;
            v_allow_subst := null;
            v_note := null;
            v_acc_id := null;
            for ak in (
                select
                    pc_lookups.get_meaning(a.plan_type, 'PLAN_TYPE_5500')              plan_type,
                    ben_plan_name,
                    a.entrp_id,
                    a.ben_plan_id,
                    a.ben_plan_number,
                    to_char(plan_start_date, 'MM/DD/YYYY')                             plan_start_date,
                    to_char(plan_end_date, 'MM/DD/YYYY')                               plan_end_date,
                    to_char(open_enrollment_start_date, 'MM/DD/YYYY')                  open_enrollment_start_date,
                    to_char(open_enrollment_end_date, 'MM/DD/YYYY')                    open_enrollment_end_date,
                    to_char(effective_date, 'MM/DD/YYYY')                              effective_date,
                    pc_lookups.get_meaning(status, 'BEN_PLAN_STATUS')                  status,
                    to_char(fiscal_end_date, 'MM/DD/YYYY')                             fiscal_end_date,
                    pc_lookups.get_meaning(takeover, 'YES_NO')                         takeover,
                    to_char(original_eff_date, 'MM/DD/YYYY')                           original_eff_date,
                    to_char(amendment_date, 'MM/DD/YYYY')                              amendment_date,
                    pc_lookups.get_meaning(plan_docs_flag, 'YES_NO')                   plan_docs_flag,
                    pc_lookups.get_meaning(non_discrm_flag, 'YES_NO')                  non_discrm_flag,
                    minimum_election,
                    maximum_election,
                    payroll_contrib,
                    (
                        select
                            meaning
                        from
                            funding_option
                        where
                            lookup_code = funding_options
                    )                                                                  funding_options_old,
                    pc_lookups.get_meaning(rollover, 'YES_NO')                         rollover,
                    decode(new_hire_contrib, 'PRORATE', 'Prorate', 'No')               new_hire_contrib,
                    to_char(effective_end_date, 'MM/DD/YYYY')                          effective_end_date,
                    to_char(termination_req_date, 'MM/DD/YYYY')                        termination_req_date,
                    pc_lookups.get_meaning(term_eligibility, 'YES_NO')                 term_eligibility,
                    runout_period_days,
                    runout_period_term,
                    grace_period,
                    pc_lookups.get_meaning(transaction_period, 'ACC_PAY_PERIOD')       transaction_period,
                    transaction_limit,
                    pc_lookups.get_meaning(iias_enable, 'IIAS_ENABLE')                 iias_enable,
                    pc_lookups.get_meaning(claim_reimbursed_by, 'CLAIM_REIMBURSED_BY') claim_reimbursed_by,
                    to_char(reimburse_start_date, 'MM/DD/YYYY')                        reimburse_start_date,
                    to_char(reimburse_end_date, 'MM/DD/YYYY')                          reimburse_end_date,
                    pc_lookups.get_meaning(allow_substantiation, 'YES_NO')             allow_substantiation,
                    a.note,
                    a.acc_id,
                            --PC_BROKER.GET_BROKER_NAME(B.BROKER_ID) BROKER_ADDED  ,
                            ---PC_SALES_TEAM.GET_GENERAL_AGENT_NAME(B.GA_ID) GA_ADDED ,
                    plan_end_date                                                      plan_end_date1,
                    a.creation_date,
                    plan_funding_code,
                    plan_benefit_code,
                    is_collective_plan
                from
                    ben_plan_enrollment_setup a,
                    account                   b
                where
                        a.acc_id = b.acc_id
                    and ben_plan_id = (
                        select
                            max(ben_plan_id)
                        from
                            ben_plan_enrollment_setup
                        where
                                ben_plan_id != l_ben_plan_new(i).ben_plan_id
                            and ben_plan_number = l_ben_plan_new(i).ben_plan_number  --- rprabu 18/10/2019
                            and acc_id = l_ben_plan_new(i).acc_id
                            and status = 'A'
                            and plan_type in ( 'SNGL', 'SNGL_RENEW', 'MER', 'MER_RENEW', 'MERS_RENEW',
                                               'MERS' )
                                                  ---   group by  BEN_PLAN_ID having count(BEN_PLAN_ID) > 1  --- 8520 rprabu
                    )
                    and rownum = 1
            ) loop
                v_old_data := 'Y';
                v_plan_type := ak.plan_type;
                v_ben_plan_name := ak.ben_plan_name;
                v_ben_plan_id := ak.ben_plan_id;
                v_entrp_id := ak.entrp_id;
                v_ben_plan_number := ak.ben_plan_number;
                v_plan_start_date := ak.plan_start_date;
                v_plan_end_date := ak.plan_end_date;
                v_collective_plan_flag := ak.is_collective_plan;
                v_plan_funding_code := ak.plan_funding_code;
                v_plan_benefit_code := ak.plan_benefit_code;

 -- dbms_output.PUT_LINE('ERROR 3');
                v_late_report_old :=
                    case
                        when trunc(ak.creation_date) > trunc(ak.plan_end_date1) then
                            'Yes'
                        else 'No'
                    end;

                begin
                    select
                        count(*)
                    into v_special_instruction_old
                    from
                        notes
                    where
                            entity_id = ak.ben_plan_id
                        and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                        and note_action = 'SPECIAL_INSTRUCTIONS'
                        and trunc(creation_date) between trunc(ak.creation_date) and trunc(l_ben_plan_new(i).creation_date) + 1;

                end;

               -- dbms_output.PUT_LINE('ERROR  11 ');
                ---  broker  name
                for x in (
                    select
                        first_name
                    from
                        contact_leads
                    where
                            contact_type = 'BROKER'
                        and entity_id = pc_entrp.get_tax_id(to_char(l_ben_plan_new(i).entrp_id))
                        and account_type = 'FORM_5500'
                        and lic_number is not null
                        and rownum < 2
                ) loop
                    v_broker_added_new := x.first_name;
                                         -- dbms_output.PUT_LINE('ERROR  12 name  '||x.First_name);
                end loop;

               -- dbms_output.PUT_LINE('ERROR  12 ');
                                 ---  General agent   name
                for x in (
                    select
                        first_name
                    from
                        contact_leads
                    where
                            contact_type = 'GA'
                        and entity_id = to_char(pc_entrp.get_tax_id(to_char(l_ben_plan_new(i).entrp_id)))
                        and account_type = 'FORM_5500'
                        and lic_number is not null
                        and rownum < 2
                ) loop
                    v_ga_added_new := x.first_name;
                end loop;

               -- dbms_output.PUT_LINE('ERROR  13 ');

                                ---  broker  contact name
                for x in (
                    select
                        first_name
                    from
                        contact_leads
                    where
                            contact_type = 'BROKER'
                        and entity_id = pc_entrp.get_tax_id(to_char(l_ben_plan_new(i).entrp_id))
                        and account_type = 'FORM_5500'
                        and lic_number is null
                        and rownum < 2
                ) loop
                    v_broker_contact_new := x.first_name;
                end loop;
                              -- dbms_output.PUT_LINE('ERROR  14 ');

                                 ---  General agent   contact  name
                for x in (
                    select
                        first_name
                    from
                        contact_leads
                    where
                            contact_type = 'GA'
                        and entity_id = pc_entrp.get_tax_id(to_char(l_ben_plan_new(i).entrp_id))
                        and account_type = 'FORM_5500'
                        and lic_number is null
                        and rownum < 2
                ) loop
                    v_ga_contact_new := x.first_name;
                end loop;

                              -- dbms_output.PUT_LINE('ERROR  15 ');

               -- dbms_output.PUT_LINE('ERROR  4 ');
                /*
             ------- broker contact and general agent contact .....
              FOR J IN (SELECT LISTAGG(FIRST_NAME, ',') WITHIN GROUP (ORDER BY FIRST_NAME) FIRST_NAME
                         FROM (SELECT DISTINCT  FIRST_NAME FIRST_NAME
                            FROM CONTACT_LEADS
                           WHERE CONTACT_TYPE = 'BROKER'
                             AND REF_ENTITY_ID    =  AK.BEN_PLAN_ID
                             AND REF_ENTITY_TYPE  = 'BEN_PLAN_ENROLLMENT_SETUP')) LOOP
               V_BROKER_CONTACT := J.FIRST_NAME;
           END LOOP;

           FOR J IN ( SELECT LISTAGG(FIRST_NAME, ',') WITHIN GROUP (ORDER BY FIRST_NAME) FIRST_NAME
                     FROM
                        (SELECT DISTINCT FIRST_NAME FIRST_NAME
                           FROM CONTACT_LEADS
                          WHERE CONTACT_TYPE = 'GA'
                             AND REF_ENTITY_ID    =  AK.BEN_PLAN_ID
                             AND REF_ENTITY_TYPE  = 'BEN_PLAN_ENROLLMENT_SETUP')) LOOP
                    V_GA_CONTACT := J.FIRST_NAME;
           END LOOP; */

                  ------ rprabu 8135
                begin
                    v_company_address := '0';
                    select
                        nvl(note_id, 0)
                    into v_company_address
                    from
                        notes
                    where
                            entity_id = l_ben_plan_new(i).entrp_id
                        and entity_type = 'ENTERPRISE'
                        and trunc(creation_date) between trunc(l_ben_plan_new(i).creation_date) and trunc(l_ben_plan_new(i).creation_date
                        ) + 1
                                                                                                                                         and
                                                                                                                                         upper
                                                                                                                                         (
                                                                                                                                         description
                                                                                                                                         )
                                                                                                                                         like
                                                                                                                                         upper
                                                                                                                                         (
                                                                                                                                         '%Address changed%'
                                                                                                                                         )
                                                                                                                                         ;

                exception
                    when no_data_found then
                        null;
                end;

                if v_company_address = '0' then
                    v_company_address := 'No';
                else
                    v_company_address := 'Yes';
                end if;

               /*   v_broker_added_Old := ak.BROKER_ADDED;
                  v_GA_added_Old := ak.GA_ADDED;
                  v_broker_added_New :=   ak.BROKER_ADDED;
                  v_GA_added_New       := ak.GA_ADDED;    8523 */

               -- dbms_output.PUT_LINE('ERROR  5 ');

                begin
                    select
                        count(*)
                    into v_ben_code_change_old
                    from
                        benefit_codes
                    where
                            entity_id = ak.ben_plan_id
                        and entity_type = 'SUBSIDIARY_CONTRACT';

                exception
                    when no_data_found then
                        null;
                end;

                v_no_of_eligible := get_census_number(ak.entrp_id, 'NO_OF_ELIGIBLE ', ak.ben_plan_id);
                v_active_participant := get_census_number(ak.entrp_id, 'ACTIVE_PARTICIPANT ', ak.ben_plan_id);
                v_retired_sep_ben := get_census_number(ak.entrp_id, 'RETIRED_SEP_BEN ', ak.ben_plan_id);
                v_retired_sep_fut_ben := get_census_number(ak.entrp_id, 'RETIRED_SEP_FUT_BEN ', ak.ben_plan_id);
                v_last_day_active_participant := get_census_number(ak.entrp_id, 'LAST_DAY_ACTIVE_PARTICIPANT ', ak.ben_plan_id);
                v_enrd_emp_1st_day_nxt_pln_yr := get_census_number(ak.entrp_id, 'ENRD_EMP_1ST_DAY_NXT_PLN_YR ', ak.ben_plan_id);
                v_no_of_eligible_new := get_census_number(l_ben_plan_new(i).entrp_id,
                                                          'NO_OF_ELIGIBLE ',
                                                          l_ben_plan_new(i).ben_plan_id);

                v_active_participant_new := get_census_number(l_ben_plan_new(i).entrp_id,
                                                              'ACTIVE_PARTICIPANT ',
                                                              l_ben_plan_new(i).ben_plan_id);

                v_retired_sep_ben_new := get_census_number(l_ben_plan_new(i).entrp_id,
                                                           'RETIRED_SEP_BEN ',
                                                           l_ben_plan_new(i).ben_plan_id);

                v_retired_sep_fut_ben_new := get_census_number(l_ben_plan_new(i).entrp_id,
                                                               'RETIRED_SEP_FUT_BEN ',
                                                               l_ben_plan_new(i).ben_plan_id);

                v_last_day_active_partici_new := get_census_number(l_ben_plan_new(i).entrp_id,
                                                                   'LAST_DAY_ACTIVE_PARTICIPANT ',
                                                                   l_ben_plan_new(i).ben_plan_id);

                v_emp_1st_day_nxt_pln_yr_new := get_census_number(l_ben_plan_new(i).entrp_id,
                                                                  'ENRD_EMP_1ST_DAY_NXT_PLN_YR ',
                                                                  l_ben_plan_new(i).ben_plan_id);

                v_open_enr_start_date := ak.open_enrollment_start_date;
                v_open_enr_end_date := ak.open_enrollment_end_date;
                v_effect_date := ak.effective_date;
                v_status := ak.status;
                v_fiscal_end_date := ak.fiscal_end_date;
                v_takeover := ak.takeover;
                v_orig_eff_date := ak.original_eff_date;
                v_amend_date := ak.amendment_date;
                v_plan_docs_flag := ak.plan_docs_flag;
                v_non_discrm_flag := ak.non_discrm_flag;
                v_min_election := ak.minimum_election;
                v_max_election := ak.maximum_election;
                v_payroll_contrib := ak.payroll_contrib;
                v_funding_options_old := ak.funding_options_old;
                v_is_collective_plan_old := ak.is_collective_plan;
                v_rollover := ak.rollover;
                v_new_hire_contrib := ak.new_hire_contrib;
                v_effect_end_date := ak.effective_end_date;
                v_term_req_date := ak.termination_req_date;
                v_term_elig := ak.term_eligibility;
                v_runout_period_days := ak.runout_period_days;
                v_runout_period_term := ak.runout_period_term;
                v_grace_period := ak.grace_period;
                v_tran_period := ak.transaction_period;
                v_tran_limit := ak.transaction_limit;
                v_iias_enable := ak.iias_enable;
                v_claim_reimb_by := ak.claim_reimbursed_by;
                v_reimb_start_date := ak.reimburse_start_date;
                v_reimb_end_date := ak.reimburse_end_date;
                v_allow_subst := ak.allow_substantiation;
                v_note := ak.note;
            end loop;
     ------- broker contact and general agent contact .....
            for j in (
                select
                    listagg(first_name, ',') within group(
                    order by
                        first_name
                    ) first_name
                from
                    (
                        select distinct
                            first_name first_name
                        from
                            contact_leads
                        where
                                contact_type = 'BROKER'
                            and entity_id = pc_entrp.get_tax_id(l_ben_plan_new(i).entrp_id)
                            and account_type = 'FORM_5500'
                            and lic_number is null
                        order by
                            contact_id desc
                    )
            ) loop
                v_broker_contact_new := j.first_name;
            end loop;

               -- dbms_output.PUT_LINE('ERROR  6');

            for j in (
                select
                    listagg(first_name, ',') within group(
                    order by
                        first_name
                    ) first_name
                from
                    (
                        select distinct
                            first_name first_name
                        from
                            contact_leads
                        where
                                contact_type = 'GA'
                            and entity_id = pc_entrp.get_tax_id(l_ben_plan_new(i).entrp_id)
                            and account_type = 'FORM_5500'
                            and lic_number is null
                    )
            ) loop
                v_ga_contact_new := j.first_name;
            end loop;
             ------ rprabu 8135
            begin
                v_company_address_new := 0;
                select
                    nvl(note_id, 0)
                into v_company_address_new
                from
                    notes
                where
                        entity_id = l_ben_plan_new(i).entrp_id
                    and entity_type = 'ENTERPRISE'
                    and creation_date > trunc(sysdate) - 1
                                                         and upper(description) like upper('%Address changed%');

            exception
                when no_data_found then
                    null;
            end;

            if v_company_address_new = '0' then
                v_company_address_new := 'No';
            else
                v_company_address_new := 'Yes';
            end if;

            select
                pc_lookups.get_meaning(l_ben_plan_new(i).plan_type,
                                       'PLAN_TYPE_5500'),
                get_census_number(l_ben_plan_new(i).entrp_id,
                                  'NO_OF_ELIGIBLE ',
                                  l_ben_plan_new(i).ben_plan_id)
            into
                v_plan_type_new,
                v_no_of_eligible_new
            from
                dual;

            l_line_no := 0;
            l_line_no := l_line_no + 1;
            gen_xl_xml.set_column_width(1, 135, v_work_sheet);
           --Plan Setup Work sheet Header
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Employer Name(Account Number)', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_char(l_line_no,
                                       r + 1,
                                       v_work_sheet,
                                       pc_entrp.get_entrp_name(l_ben_plan_new(i).entrp_id)
                                       || '('
                                       || pc_entrp.get_acc_num(l_ben_plan_new(i).entrp_id)
                                       || ')',
                                       'BEN_PLAN_COLUMN');

            gen_xl_xml.write_cell_null(l_line_no, r + 2, v_work_sheet, 'BEN_PLAN_HEADER');
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_null(l_line_no, r, v_work_sheet, 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
              --GEN_XL_XML.WRITE_CELL_CHAR( 2,  R+1, V_WORK_SHEET , 'Renewed Plan',  'BEN_PLAN_HEADER_BEN_PLAN1' );
                gen_xl_xml.write_cell_null(l_line_no, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            else
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, 'Renewed Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
                gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, 'Previous Plan', 'BEN_PLAN_HEADER_BEN_PLAN1');
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Setup', 'BEN_PLAN_HEADER_BEN_PLAN');
            gen_xl_xml.write_cell_null(l_line_no, r + 1, v_work_sheet, 'BEN_PLAN_COLUMN');
            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Type', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).plan_type,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(v_plan_type_new, 0) != nvl(v_plan_type, 0) then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_plan_type_new, 'BEN_PLAN_COLUMN_CHG');
                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_type, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_plan_type_new, 'BEN_PLAN_COLUMN');
                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_type, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Name', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).ben_plan_name,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).ben_plan_name,
                       0) != nvl(v_ben_plan_name, 0) then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ben_plan_name,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_ben_plan_name, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ben_plan_name,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_ben_plan_name, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Number', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).ben_plan_number,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).ben_plan_name,
                       0) != nvl(v_ben_plan_name, 0) then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ben_plan_number,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_ben_plan_number, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).ben_plan_number,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_ben_plan_number, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Company Address', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_company_address_new, 'BEN_PLAN_COLUMN');
            else
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_company_address_new, 'BEN_PLAN_COLUMN');
                gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_company_address, 'BEN_PLAN_COLUMN');
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Start Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).plan_start_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).plan_start_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_plan_start_date, 0) then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).plan_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_start_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).plan_start_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_start_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan End Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).plan_end_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).plan_end_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_plan_end_date, 0) then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).plan_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_end_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).plan_end_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_end_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            v_no_of_eligible_new := get_census_number(l_ben_plan_new(i).entrp_id,
                                                      'NO_OF_ELIGIBLE',
                                                      l_ben_plan_new(i).ben_plan_id);

            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'No of eligible employees', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_num(l_line_no, r + 1, v_work_sheet, v_no_of_eligible_new, 'BEN_PLAN_COLUMN');
            else
                if v_no_of_eligible != v_no_of_eligible_new then
                    gen_xl_xml.write_cell_num(l_line_no, r + 1, v_work_sheet, v_no_of_eligible_new, 'BEN_PLAN_COLUMN_CHG');
                    gen_xl_xml.write_cell_num(l_line_no, r + 2, v_work_sheet, v_no_of_eligible, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_num(l_line_no, r + 1, v_work_sheet, v_no_of_eligible_new, 'BEN_PLAN_COLUMN');
                    gen_xl_xml.write_cell_num(l_line_no, r + 2, v_work_sheet, v_no_of_eligible, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Effective Date', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           to_char(l_ben_plan_new(i).effective_date,
                                                   'MM/DD/YYYY'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    to_char(l_ben_plan_new(i).effective_date,
                            'MM/DD/YYYY'),
                    0
                ) != nvl(v_effect_date, 0) then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).effective_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_effect_date, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               to_char(l_ben_plan_new(i).effective_date,
                                                       'MM/DD/YYYY'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_effect_date, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Status', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           pc_lookups.get_meaning(l_ben_plan_new(i).status,
                                                                  'BEN_PLAN_STATUS'),
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(
                    pc_lookups.get_meaning(l_ben_plan_new(i).status,
                                           'BEN_PLAN_STATUS'),
                    0
                ) != nvl(v_status, 0) then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).status,
                                                                      'BEN_PLAN_STATUS'),
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_status, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               pc_lookups.get_meaning(l_ben_plan_new(i).status,
                                                                      'BEN_PLAN_STATUS'),
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_status, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
            begin
                select
                    count(*)
                into v_ben_code_change
                from
                    benefit_codes
                where
                        entity_id = l_ben_plan_new(i).ben_plan_id
                    and entity_type = 'SUBSIDIARY_CONTRACT';

            exception
                when no_data_found then
                    null;
            end;

            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Welfare benefit plan Appendix', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet,
                                       case
                                           when v_ben_code_change > 0 then
                                               'Yes'
                                           else 'No'
                                       end, 'BEN_PLAN_COLUMN');

            gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet,
                                       case
                                           when v_ben_code_change_old > 0 then
                                               'Yes'
                                           else 'No'
                                       end, 'BEN_PLAN_COLUMN');

           -- dbms_output.PUT_LINE('9');

            l_line_no := l_line_no + 1;
----------------------------------------

   -- dbms_output.PUT_LINE('ERROR  7');

            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Broker Added ?', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_broker_added_new, 'BEN_PLAN_COLUMN');
            else
                if nvl(v_broker_added_old, 'S') != nvl(v_broker_added_new, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_broker_added_new, 'BEN_PLAN_COLUMN_CHG');
                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_broker_added_old, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_broker_added_new, 'BEN_PLAN_COLUMN');
                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_broker_added_old, 'BEN_PLAN_COLUMN');
                end if;
            end if;
                                  -- dbms_output.PUT_LINE('11');

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'General Agent Added ?', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_ga_added_new, 'BEN_PLAN_COLUMN');
            else
                if nvl(v_ga_added_new, 'S') != nvl(v_ga_added_old, 'S') then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_ga_added_new, 'BEN_PLAN_COLUMN_CHG');
                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_ga_added_old, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_ga_added_new, 'BEN_PLAN_COLUMN');
                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_ga_added_old, 'BEN_PLAN_COLUMN');
                end if;
            end if;

            l_line_no := l_line_no + 1;
               -- dbms_output.PUT_LINE('12');
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Broker Contact', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_broker_contact_new, 'BEN_PLAN_COLUMN');
          ---  GEN_XL_XML.WRITE_CELL_CHAR( l_line_no, R+1, V_WORK_SHEET , REPLACE(REPLACE(V_BROKER_CONTACT,'>',''),'<','') , 'BEN_PLAN_COLUMN' );

            l_line_no := l_line_no + 1; --Added by Puja
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'GA Contact', 'BEN_PLAN_HEADER');
            gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_ga_contact_new, 'BEN_PLAN_COLUMN');
           ----GEN_XL_XML.WRITE_CELL_CHAR( l_line_no, R+1, V_WORK_SHEET , REPLACE(REPLACE(V_GA_CONTACT,'>',''),'<','') , 'BEN_PLAN_COLUMN' );
           -- dbms_output.PUT_LINE('13');
----------------------------------------

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Note', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           l_ben_plan_new(i).note,
                                           'BEN_PLAN_COLUMN');
            else
                if nvl(l_ben_plan_new(i).note,
                       0) != nvl(v_note, 0) then
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).note,
                                               'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_note, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_ben_plan_new(i).note,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_note, 'BEN_PLAN_COLUMN');
                end if;
            end if;

           /*     SELECT COUNT(*)
                    INTO V_SPEcIAL_INSTRUCTION
                    FROM NOTES
                      WHERE ENTITY_ID =  L_Ben_Plan_New(I).Ben_Plan_Id
                      AND   ENTITY_TYPE = 'BEN_PLAN_ENROLLMENT_SETUP'
                      AND   NOTE_ACTION = 'SPECIAL_INSTRUCTIONS'
                      AND   CREATION_DATE >TRUNC(SYSDATE)-1;
            l_line_no := l_line_no+1;
            GEN_XL_XML.WRITE_CELL_CHAR( l_line_no, R,   V_WORK_SHEET , 'Special instructions', 'BEN_PLAN_HEADER' );
            GEN_XL_XML.WRITE_CELL_CHAR( l_line_no, R+1, V_WORK_SHEET ,CASE WHEN V_SPEcIAL_INSTRUCTION > 0 THEN 'Yes' ELSE 'No' END , 'BEN_PLAN_COLUMN' );
            GEN_XL_XML.WRITE_CELL_CHAR( l_line_no, R+2, V_WORK_SHEET ,CASE WHEN V_SPEcIAL_INSTRUCTION_old > 0 THEN 'Yes' ELSE 'No' END , 'BEN_PLAN_COLUMN' );
           */

 -- dbms_output.PUT_LINE(' before who will filing as the Employer/Plan Spon :  '  ||  L_BEN_PLAN_NEW(I).ben_plan_number  );

 -- dbms_output.PUT_LINE(' before who will filing as the Employer/Plan Spon 2  :  '  ||   L_BEN_PLAN_NEW(I).entrp_id);

         -------------------------------- Form 5558 extension  --------------
         -- dbms_output.PUT_LINE('ERROR 8');

            v_plan_notice_id_new := 'No';
            v_plan_notice_id_old := 'No';
            begin
                select
                    max('Yes')
                into v_plan_notice_id_new
                from
                    plan_notices
                where
                        entrp_id = l_ben_plan_new(i).entrp_id
                    and entity_id = l_ben_plan_new(i).ben_plan_id
                    and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                    and notice_type = 'FORM_5558';

            exception
                when no_data_found then
                    v_plan_notice_id_new := 'No';
            end;

            begin
                select
                    max('Yes')
                into v_plan_notice_id_old
                from
                    plan_notices
                where
                        entrp_id = v_entrp_id
                    and entity_id = v_ben_plan_id
                    and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                    and notice_type = 'FORM_5558';

            exception
                when no_data_found then
                    v_plan_notice_id_new := 'No';
            end;

             /*
             -------------is this being filed as a next plan year
              l_line_no := l_line_no+1;
            V_late_report_new  := CASE WHEN   Trunc(sysdate)  >  Trunc(L_BEN_PLAN_NEW(I).plan_end_Date)    THEN 'Yes' ELSE 'No' END;

            GEN_XL_XML.WRITE_CELL_CHAR( l_line_no, R,   V_WORK_SHEET , 'Is this being filed as a late report?', 'BEN_PLAN_HEADER' );
           IF V_OLD_DATA = 'N' THEN
              GEN_XL_XML.WRITE_CELL_CHAR( l_line_no, R+1, V_WORK_SHEET , V_late_report_new, 'BEN_PLAN_COLUMN' );
           ELSE
              IF NVL(V_late_report_new,0) != NVL(V_late_report_old,0) THEN
                 GEN_XL_XML.WRITE_CELL_CHAR( l_line_no,  R+1, V_WORK_SHEET ,  V_late_report_new, 'BEN_PLAN_COLUMN_CHG' );
                 GEN_XL_XML.WRITE_CELL_CHAR( l_line_no,  R+2, V_WORK_SHEET ,V_late_report_old, 'BEN_PLAN_COLUMN_CHG' );
              ELSE
                 GEN_XL_XML.WRITE_CELL_CHAR( l_line_no,  R+1, V_WORK_SHEET , V_late_report_new, 'BEN_PLAN_COLUMN' );
                 GEN_XL_XML.WRITE_CELL_CHAR( l_line_no,  R+2, V_WORK_SHEET , V_late_report_old, 'BEN_PLAN_COLUMN' );
              END IF;
           END IF; */
  -- dbms_output.PUT_LINE('ERROR 9');
           ----- Is  this a collectively-bargained plan?
            l_line_no := l_line_no + 1;
            v_is_collective_plan_new := l_ben_plan_new(i).is_collective_plan;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Is this a collectively-bargained plan? ', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet,
                                           case
                                               when v_is_collective_plan_new = 'Y' then
                                                   'Yes'
                                               else 'No'
                                           end, 'BEN_PLAN_COLUMN');
            else
                if nvl(v_plan_notice_id_new, 0) != nvl(v_plan_notice_id_old, 0) then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet,
                                               case
                                                   when v_is_collective_plan_new = 'Y' then
                                                       'Yes'
                                                   else 'No'
                                               end, 'BEN_PLAN_COLUMN_CHG');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet,
                                               case
                                                   when v_is_collective_plan_old = 'Y' then
                                                       'Yes'
                                                   else 'No'
                                               end, 'BEN_PLAN_COLUMN_CHG');

                else
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet,
                                               case
                                                   when v_is_collective_plan_new = 'Y' then
                                                       'Yes'
                                                   else 'No'
                                               end, 'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet,
                                               case
                                                   when v_is_collective_plan_old = 'Y' then
                                                       'Yes'
                                                   else 'No'
                                               end, 'BEN_PLAN_COLUMN');

                end if;
            end if;

            l_line_no := l_line_no + 1;
            gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Form 5558 extension selected ? ', 'BEN_PLAN_HEADER');
            if v_old_data = 'N' then
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_plan_notice_id_new, 'BEN_PLAN_COLUMN');
            else
                if nvl(v_plan_notice_id_new, 0) != nvl(v_plan_notice_id_old, 0) then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_plan_notice_id_new, 'BEN_PLAN_COLUMN_CHG');
                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_notice_id_old, 'BEN_PLAN_COLUMN_CHG');
                else
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_plan_notice_id_new, 'BEN_PLAN_COLUMN');
                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_plan_notice_id_old, 'BEN_PLAN_COLUMN');
                end if;
            end if;

         ------------ previous year data for employer details...
         -- dbms_output.PUT_LINE('ERROR 10');
            begin
                select
                    max(enrollment_detail_id)
                into v_enrollment_detail_id_new
                from
                    online_form_5500_staging      a,
                    online_form_5500_plan_staging b
                where
                        b.entrp_id = l_ben_plan_new(i).entrp_id
                    and b.entrp_id = a.entrp_id
                    and status = 'C'
                    and plan_number = l_ben_plan_new(i).ben_plan_number;

            exception
                when no_data_found then
                    null;
            end;

            if v_enrollment_detail_id_new is not null then
                for z in (
                    select
                        plan_admin_individual_name,
                        emp_plan_sponsor_ind_name,
                        disp_annual_report_phone_no,
                        decode(form_5500_sub_option_flag, 'Y', 'Sterling', 'Employer') filing,
                        erisa_wrap_flag,
                        collective_plan_flag,
                        plan_fund_code,
                        plan_benefit_code,
                        total_no_ee,
                        is_coll_plan,
                        decode(admin_name_sameas_sponsor_flag, 'Y', 'Yes', 'No')       admin_name_sameas_sponsor_flag,
                        sponsor_business_code,
                        next_yr_plan_start_date,
                        next_yr_plan_end_date
                    from
                        online_form_5500_staging      x,
                        online_form_5500_plan_staging y
                    where
                            x.entrp_id = y.entrp_id
                        and x.batch_number = y.batch_number
                        and y.plan_number = l_ben_plan_new(i).ben_plan_number
                        and y.enrollment_detail_id = (
                            select
                                max(enrollment_detail_id)
                            from
                                online_form_5500_staging      a,
                                online_form_5500_plan_staging b
                            where
                                    b.entrp_id = l_ben_plan_new(i).entrp_id
                                and b.entrp_id = a.entrp_id
                                and status = 'C'
                                and b.enrollment_detail_id < v_enrollment_detail_id_new
                                and b.plan_number = l_ben_plan_new(i).ben_plan_number
                        )
                ) loop

                              -- dbms_output.put_line('In loop : '|| V_emp_plan_sponsor_name_Old);

                    v_annual_report_phone_no_old := z.disp_annual_report_phone_no;
                    v_filing_old := z.filing;
                    v_emp_plan_sponsor_name_old := z.emp_plan_sponsor_ind_name;       --8523 ticket prabu
                    v_emp_plan_admin_name_old := z.plan_admin_individual_name;        --8523 ticket prabu
                    v_erisa_wrap_flag_old := z.erisa_wrap_flag;
                    v_collective_plan_flag_old := z.collective_plan_flag;
                    v_plan_fund_code_old := z.plan_fund_code;
                    v_plan_benefit_code_old := z.plan_benefit_code;
                    v_total_no_ee_old := z.total_no_ee;
                    v_is_coll_plan_old := z.is_coll_plan;
                    v_admin_sameas_sponsor_old := z.admin_name_sameas_sponsor_flag;
                    v_sponsor_business_code_old := z.sponsor_business_code;
                    v_next_yr_plan_end_date_old := z.next_yr_plan_end_date;
                    v_next_yr_plan_start_date_old := z.next_yr_plan_start_date;
                end loop;
            end if;

            -- dbms_output.PUT_LINE('ERROR 11');
            for x in (
                select
                    plan_admin_individual_name,
                    emp_plan_sponsor_ind_name,
                    disp_annual_report_phone_no,
                    decode(form_5500_sub_option_flag, 'Y', 'Sterling', 'Employer') filing,
                    erisa_wrap_flag,
                    collective_plan_flag,
                    plan_fund_code,
                    plan_benefit_code,
                    total_no_ee,
                    is_coll_plan,
                    decode(admin_name_sameas_sponsor_flag, 'Y', 'Yes', 'No')       admin_name_sameas_sponsor_flag,
                    sponsor_business_code,
                    next_yr_plan_start_date,
                    next_yr_plan_end_date
                from
                    online_form_5500_staging      a,
                    online_form_5500_plan_staging b
                where
                        a.entrp_id = b.entrp_id
                    and a.batch_number = b.batch_number
                    and plan_number = l_ben_plan_new(i).ben_plan_number
                    and enrollment_detail_id = (
                        select
                            max(enrollment_detail_id)
                        from
                            online_form_5500_staging      a,
                            online_form_5500_plan_staging b
                        where
                                b.entrp_id = l_ben_plan_new(i).entrp_id
                            and b.entrp_id = a.entrp_id
                            and status = 'C'
                            and plan_number = l_ben_plan_new(i).ben_plan_number
                    )
            ) loop

 -- dbms_output.PUT_LINE('who will filing as the Employer or Sterling :  '|| x.filing);

                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, ' who will file  the Employer or  Sterling ', 'BEN_PLAN_HEADER'
                );
                if v_old_data = 'N' then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.filing, 'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_filing_old, 'BEN_PLAN_COLUMN');
                else
                    if nvl(v_filing_old, 0) != x.filing then
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.filing, 'BEN_PLAN_COLUMN_CHG');

                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_filing_old, 'BEN_PLAN_COLUMN_CHG');
                    else
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.filing, 'BEN_PLAN_COLUMN');

                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_filing_old, 'BEN_PLAN_COLUMN');
                    end if;
                end if;
----   V_Emp_Plan_Sponsor_Name_Old                              :=  z.Plan_Admin_Individual_Name;      --8523 ticket prabu
                                        ---V_Emp_Plan_Admin_Name_Old                                   := z.emp_plan_sponsor_ind_name ;    --8523 ticket prabu

        ---- 8523 ticket
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, ' Who will sign as the plan administrator ', 'BEN_PLAN_HEADER'
                );
                if v_old_data = 'N' then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.plan_admin_individual_name, 'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_emp_plan_admin_name_old, 'BEN_PLAN_COLUMN');
                else
                    if nvl(v_emp_plan_admin_name_old, 0) != x.plan_admin_individual_name then
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.plan_admin_individual_name, 'BEN_PLAN_COLUMN_CHG'
                        );

                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_emp_plan_admin_name_old, 'BEN_PLAN_COLUMN_CHG');
                    else
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.plan_admin_individual_name, 'BEN_PLAN_COLUMN');

                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_emp_plan_admin_name_old, 'BEN_PLAN_COLUMN');
                    end if;
                end if;

             ---- 8523 ticket
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, ' Who will sign as the plan Sponsor  ', 'BEN_PLAN_HEADER');
                if v_old_data = 'N' then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.emp_plan_sponsor_ind_name, 'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_emp_plan_sponsor_name_old, 'BEN_PLAN_COLUMN');
                else
                    if nvl(v_emp_plan_sponsor_name_old, 0) != x.emp_plan_sponsor_ind_name then
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.emp_plan_sponsor_ind_name, 'BEN_PLAN_COLUMN_CHG'
                        );

                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_emp_plan_sponsor_name_old, 'BEN_PLAN_COLUMN_CHG'
                        );
                    else
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.emp_plan_sponsor_ind_name, 'BEN_PLAN_COLUMN');

                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_emp_plan_sponsor_name_old, 'BEN_PLAN_COLUMN');
                    end if;
                end if;

-- dbms_output.PUT_LINE('ERROR 12');

                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Phone number to appear on the 5500 and SAR', 'BEN_PLAN_HEADER'
                );
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.disp_annual_report_phone_no, 'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_annual_report_phone_no_old, 'BEN_PLAN_COLUMN');


           -----IRS Business Code

                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'IRS Business Code', 'BEN_PLAN_HEADER');
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.sponsor_business_code, 'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_sponsor_business_code_old, 'BEN_PLAN_COLUMN');

           -- Plan Administrator's name and address the same as the Employer/Plan Sponsor
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Administrator name and address the same as the Employer/Plan Sponsor :'
                , 'BEN_PLAN_HEADER');
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.admin_name_sameas_sponsor_flag, 'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_admin_sameas_sponsor_old, 'BEN_PLAN_COLUMN');

           -------Plan Funding Arrangement
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan Funding Arrangement :', 'BEN_PLAN_HEADER');
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           pc_web_er_renewal.plan_funding(x.plan_fund_code, 'PLAN_ARRANGEMENT'),
                                           'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 2,
                                           v_work_sheet,
                                           pc_web_er_renewal.plan_funding(v_plan_fund_code_old, 'PLAN_ARRANGEMENT'),
                                           'BEN_PLAN_COLUMN');

                             -- dbms_output.PUT_LINE('x.plan_fund_code ,  : ' ||x.plan_fund_code );

                dbms_output.put_line('x.x.plan_benefit_code ,  : ' || x.plan_benefit_code);
                      -------Plan benefit  Arrangement
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Plan benefit  Arrangement :', 'BEN_PLAN_HEADER');
                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 1,
                                           v_work_sheet,
                                           pc_web_er_renewal.plan_funding(x.plan_benefit_code, 'PLAN_ARRANGEMENT'),
                                           'BEN_PLAN_COLUMN');

                gen_xl_xml.write_cell_char(l_line_no,
                                           r + 2,
                                           v_work_sheet,
                                           pc_web_er_renewal.plan_funding(v_plan_benefit_code_old, 'PLAN_ARRANGEMENT'),
                                           'BEN_PLAN_COLUMN');

              ------------------------------------------------------------------------

                dbms_output.put_line(' next_yr_plan_start_Date ,  : ' || x.next_yr_plan_start_date);
                 ---next_yr_plan_start_Date
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Next year plan start Date  :', 'BEN_PLAN_HEADER');
                if v_old_data = 'N' then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.next_yr_plan_start_date, 'BEN_PLAN_COLUMN');
                else
                    if nvl(x.next_yr_plan_start_date, 'X') != nvl(x.next_yr_plan_start_date, 'X') then
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.next_yr_plan_start_date, 'BEN_PLAN_COLUMN_CHG');

                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_next_yr_plan_start_date_old, 'BEN_PLAN_COLUMN_CHG'
                        );
                    else
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.next_yr_plan_start_date, 'BEN_PLAN_COLUMN');

                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_next_yr_plan_start_date_old, 'BEN_PLAN_COLUMN');
                    end if;
                end if;

                             -- dbms_output.PUT_LINE(' next_yr_plan_end_Date ,  : ' ||x.next_yr_plan_end_Date );
                 ---next_yr_plan_end_Date
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Next year  plan end  Date :', 'BEN_PLAN_HEADER');
                if v_old_data = 'N' then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.next_yr_plan_end_date, 'BEN_PLAN_COLUMN');
                else
                    if nvl(v_next_yr_plan_end_date_old, 'X') != nvl(x.next_yr_plan_end_date, 'X') then
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.next_yr_plan_end_date, 'BEN_PLAN_COLUMN_CHG');

                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_next_yr_plan_end_date_old, 'BEN_PLAN_COLUMN_CHG'
                        );
                    else
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, x.next_yr_plan_end_date, 'BEN_PLAN_COLUMN');

                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_next_yr_plan_end_date_old, 'BEN_PLAN_COLUMN');
                    end if;
                end if;

           ------------------------------------------------------------------------
                                 -------ACTIVE_PARTICIPANT
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Number of active employees enrolled as of the first day of the Plan Year:'
                , 'BEN_PLAN_HEADER');
                if v_old_data = 'N' then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_active_participant_new, 'BEN_PLAN_COLUMN');
                else
                    if nvl(l_ben_plan_new(i).plan_benefit_code,
                           0) != v_plan_benefit_code then
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_active_participant_new, 'BEN_PLAN_COLUMN_CHG');
                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_active_participant, 'BEN_PLAN_COLUMN_CHG');
                    else
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_active_participant_new, 'BEN_PLAN_COLUMN');
                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_active_participant, 'BEN_PLAN_COLUMN');
                    end if;
                end if;

           ---NO_OF_ELIGIBLE
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Number of employees enrolled as of the first day of the Plan Year:'
                , 'BEN_PLAN_HEADER');
                if v_old_data = 'N' then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_no_of_eligible_new, 'BEN_PLAN_COLUMN');
                else
                    if nvl(l_ben_plan_new(i).plan_benefit_code,
                           0) != v_plan_benefit_code then
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_no_of_eligible_new, 'BEN_PLAN_COLUMN_CHG');
                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_no_of_eligible, 'BEN_PLAN_COLUMN_CHG');
                    else
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_no_of_eligible_new, 'BEN_PLAN_COLUMN');
                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_no_of_eligible, 'BEN_PLAN_COLUMN');
                    end if;
                end if;

             ---RETIRED_SEP_BEN
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Number of other retired or separated employees (including COBRA) enrolled as of the last day of the Plan Year:'
                , 'BEN_PLAN_HEADER');
                if v_old_data = 'N' then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_retired_sep_ben_new, 'BEN_PLAN_COLUMN');
                else
                    if nvl(v_retired_sep_ben_new, 0) != nvl(v_retired_sep_ben, 0) then
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_retired_sep_ben_new, 'BEN_PLAN_COLUMN_CHG');
                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_retired_sep_ben, 'BEN_PLAN_COLUMN_CHG');
                    else
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_retired_sep_ben_new, 'BEN_PLAN_COLUMN');
                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_retired_sep_ben, 'BEN_PLAN_COLUMN');
                    end if;
                end if;

                     ---RETIRED_SEP_FUT_BEN
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Number of retired or separated employees covered by the Plan and who are entitled to begin receiving benefits under the Plan in the future:'
                , 'BEN_PLAN_HEADER');
                if v_old_data = 'N' then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_retired_sep_fut_ben_new, 'BEN_PLAN_COLUMN');
                else
                    if nvl(v_retired_sep_ben_new, 0) != nvl(v_retired_sep_ben, 0) then
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_retired_sep_fut_ben_new, 'BEN_PLAN_COLUMN_CHG');
                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_retired_sep_fut_ben, 'BEN_PLAN_COLUMN_CHG');
                    else
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_retired_sep_fut_ben_new, 'BEN_PLAN_COLUMN');
                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_retired_sep_fut_ben, 'BEN_PLAN_COLUMN');
                    end if;
                end if;

              ---LAST_DAY_ACTIVE_PARTICIPANT
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Number of active employees enrolled as of the last day of the Plan Year :'
                , 'BEN_PLAN_HEADER');
                if v_old_data = 'N' then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_last_day_active_partici_new, 'BEN_PLAN_COLUMN');
                else
                    if nvl(v_retired_sep_ben_new, 0) != nvl(v_retired_sep_ben, 0) then
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_last_day_active_partici_new, 'BEN_PLAN_COLUMN_CHG'
                        );
                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_last_day_active_participant, 'BEN_PLAN_COLUMN_CHG'
                        );
                    else
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_last_day_active_partici_new, 'BEN_PLAN_COLUMN');
                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_last_day_active_participant, 'BEN_PLAN_COLUMN');
                    end if;
                end if;

                ---ENRD_EMP_1ST_DAY_NXT_PLN_YR
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Number of employees enrolled as of the first day of the NEXT Plan Year:'
                , 'BEN_PLAN_HEADER');
                if v_old_data = 'N' then
                    gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_last_day_active_partici_new, 'BEN_PLAN_COLUMN');
                else
                    if nvl(v_retired_sep_ben_new, 0) != nvl(v_retired_sep_ben, 0) then
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_last_day_active_partici_new, 'BEN_PLAN_COLUMN_CHG'
                        );
                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_last_day_active_participant, 'BEN_PLAN_COLUMN_CHG'
                        );
                    else
                        gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, v_last_day_active_partici_new, 'BEN_PLAN_COLUMN');
                        gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, v_last_day_active_participant, 'BEN_PLAN_COLUMN');
                    end if;
                end if;

           -- dbms_output.PUT_LINE('ERROR 13');
              --Fetching welfare chart for new  plan

                begin
                    select
                        case
                            when a.benefit_code_name = 'OTHER' then
                                max(lkp.meaning)
                                || '-'
                                || max(a.description) ---- All Max added for  8539 rprabu 03/12/2019
                            else
                                max(lkp.meaning)
                        end description,
                        decode(
                            max(fully_insured_flag),
                            'Y',
                            'Yes',
                            'No'
                        )   fully_insured_flag,
                        decode(
                            max(self_insured_flag),
                            'Y',
                            'Yes',
                            'No'
                        )   self_insured_flag
                    bulk collect
                    into l_benefit_code_new
                    from
                        benefit_codes a,
                        lookups       lkp
                    where
                            entity_id = l_ben_plan_new(i).ben_plan_id
                        and lkp.lookup_code = a.benefit_code_name
                    group by
                        benefit_code_name;---- 8539 rprabu 03/12/2019
                exception
                    when no_data_found then
                        null;
                end;

                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, 'Welfare Chart(Renewed)', 'BEN_PLAN_COLUMN_CHG');
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Welfare Benefit Plan Name', 'BEN_PLAN_HEADER');
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, 'Fully insured flag', 'BEN_PLAN_HEADER');
                gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, 'Self insured flag', 'BEN_PLAN_HEADER');
                l_line_no := l_line_no + 1;
                for x in 1..l_benefit_code_new.count loop
                    gen_xl_xml.write_cell_char(l_line_no,
                                               r,
                                               v_work_sheet,
                                               l_benefit_code_new(x).description,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 1,
                                               v_work_sheet,
                                               l_benefit_code_new(x).fully_insured_flag,
                                               'BEN_PLAN_COLUMN');

                    gen_xl_xml.write_cell_char(l_line_no,
                                               r + 2,
                                               v_work_sheet,
                                               l_benefit_code_new(x).self_insured_flag,
                                               'BEN_PLAN_COLUMN');

                    l_line_no := l_line_no + 1;
                end loop;

           ------------------------------------------------------------------------
           -- dbms_output.PUT_LINE('ERROR 14');
              --Fetching welfare chart for old plan

                begin
                    select
                        case
                            when a.benefit_code_name = 'OTHER' then
                                max(lkp.meaning)
                                || '-'
                                || max(a.description) ---- All Max added for  8539 rprabu 03/12/2019
                            else
                                max(lkp.meaning)
                        end description,
                        decode(
                            max(fully_insured_flag),
                            'Y',
                            'Yes',
                            'No'
                        )   fully_insured_flag,
                        decode(
                            max(self_insured_flag),
                            'Y',
                            'Yes',
                            'No'
                        )   self_insured_flag
                    bulk collect
                    into l_benefit_code_old
                    from
                        benefit_codes a,
                        lookups       lkp
                    where
                            entity_id = v_ben_plan_id
                        and lkp.lookup_code = a.benefit_code_name
                    group by
                        benefit_code_name;---- 8539 rprabu 03/12/2019

                exception
                    when no_data_found then
                        null;
                end;

                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, 'Welfare Chart(Previous)', 'BEN_PLAN_COLUMN_CHG');
                l_line_no := l_line_no + 1;
                gen_xl_xml.write_cell_char(l_line_no, r, v_work_sheet, 'Welfare Benefit Plan Name', 'BEN_PLAN_HEADER');
                gen_xl_xml.write_cell_char(l_line_no, r + 1, v_work_sheet, 'Fully insured flag', 'BEN_PLAN_HEADER');
                gen_xl_xml.write_cell_char(l_line_no, r + 2, v_work_sheet, 'Self insured flag', 'BEN_PLAN_HEADER');
                if v_old_data = 'Y' then
                    l_line_no := l_line_no + 1;
                    for y in 1..l_benefit_code_old.count loop
                        gen_xl_xml.write_cell_char(l_line_no,
                                                   r,
                                                   v_work_sheet,
                                                   l_benefit_code_old(y).description,
                                                   'BEN_PLAN_COLUMN');

                        gen_xl_xml.write_cell_char(l_line_no,
                                                   r + 1,
                                                   v_work_sheet,
                                                   l_benefit_code_old(y).fully_insured_flag,
                                                   'BEN_PLAN_COLUMN');

                        gen_xl_xml.write_cell_char(l_line_no,
                                                   r + 2,
                                                   v_work_sheet,
                                                   l_benefit_code_old(y).self_insured_flag,
                                                   'BEN_PLAN_COLUMN');

                        l_line_no := l_line_no + 1;
                    end loop;

                end if;   --- 8520

           ------------------------------------------------------------------------

            end loop;

        end loop;
-- dbms_output.PUT_LINE('ERROR 15');

--ACTIVE_PARTICIPANT    Number of active employees enrolled as of the first day of the Plan Year:
--RETIRED_SEP_BEN  Number of other retired or separated employees (including COBRA) enrolled as of the last day of the Plan Year:
--RETIRED_SEP_FUT_BEN Number of retired or separated employees covered by the Plan and who are entitled to begin receiving benefits under the Plan in the future
---NO_OF_ELIGIBLE          Number of employees enrolled as of the first day of the Plan Year:
----LAST_DAY_ACTIVE_PARTICIPANT  Number of active employees enrolled as of the last day of the Plan Year
----ENRD_EMP_1ST_DAY_NXT_PLN_YR  Number of employees enrolled as of the first day of the NEXT Plan Year

        -- dbms_output.put_line('In Loop5..');
        if l_ben_plan_new.count > 0 then --- OR L_BEN_PLAN_RENEW_NEW.COUNT > 0  THEN
            gen_xl_xml.close_file;
        end if;
        v_email := 'IT-team@sterlingadministration.com';
          ----         V_email :=  'r.prabu@sterlingadministration.com';
        dbms_output.put_line('Filename..Loop out..' || v_file_name);
        if file_exists(v_file_name, 'MAILER_DIR') = 'TRUE' then
            dbms_output.put_line('Email..' || v_email);
            v_html_msg := '<html><body><br>
                  <p>Daily Form 5500 Renewal Changes Report for the Date '
                          || to_char(sysdate, 'MM/DD/YYYY')
                          || ' </p> <br> <br>
                   </body></html>';
            if user = 'SAM' then
                v_email := 'clientservices@sterlingadministration.com,Renewals@sterlingadministration.com'
                           || ',dan.tidball@sterlingadministration.com,DL_Sales@sterlingadministration.com'
                           || ',sarah.soman@sterlingadministration.com,IT-Team@sterlingadministration.com'
                           || ',VHSTeam@sterlingadministration.com';
            else
                v_email := 'IT-team@sterlingadministration.com';
           ----   V_email :=  ' r.prabu@sterlingadministration.com';
                dbms_output.put_line('Email..Else..' || v_email);
            end if;

            mail_utility.send_file_in_emails(
                p_from_email   => 'oracle@sterlinghsa.com',
                p_to_email     => v_email,
                p_file_name    => v_file_name,
                p_sql          => null,
                p_html_message => v_html_msg,
                p_report_title => 'Daily FORM 5500 Renewal Changes Report for the Date ' || to_char(sysdate, 'MM/DD/YYYY')
            );

            if p_acc_id is not null then
                pc_crm_interface.export_changes_report(p_acc_id, v_file_name);
            end if;
        end if;

    exception
        when no_data_found then
            dbms_output.put_line('ERROR '
                                 || ' '
                                 || sqlerrm
                                 || ' '
                                 || sqlcode);
        when others then
            dbms_output.put_line('ERROR '
                                 || ' '
                                 || sqlerrm
                                 || ' '
                                 || sqlcode);
    end pos_renewal_det_form_5500;

          -------------- 8135 form 5500 06/11/2019
    function get_census_number (
        p_entrp_id    number,
        p_census_code varchar2,
        p_ben_plan_id number
    ) return number is
        l_census_numbers number;
        x_error_message  varchar2(300);
        x_error_status   varchar2(20);
    begin
        begin
            select
                census_numbers
            into l_census_numbers
            from
                enterprise_census
            where
                    trim(census_code) = trim(p_census_code)
                and entity_id = p_entrp_id
                and ben_plan_id = p_ben_plan_id;

        exception
            when no_data_found then
                l_census_numbers := 0;
        end;

        return l_census_numbers;
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('pc_web_er_renewal.Get_Census_number ', 'Error ' || sqlerrm);
    end get_census_number;
-----------------------------------------------------
    function plan_funding (
        p_plan_fund_code varchar2,
        p_plan_fund_name varchar2
    ) return varchar2 as

        l_mno1 number;
        l_mno2 number;
        l_str1 varchar2(1000);
        l_str2 varchar2(1000);
        l_str3 varchar2(1000);
    begin
        if p_plan_fund_code is null then
            return '';
        end if;
        for i in 1..length(p_plan_fund_code) loop
            if substr(p_plan_fund_code, i, 1) <> ':' then
                l_str2 := l_str2
                          || substr(p_plan_fund_code, i, 1);
            else
                begin
                    select
                        meaning
                    into l_str3
                    from
                        lookups
                    where
                            lookup_name = 'PLAN_ARRANGEMENT'
                        and lookup_code = l_str2;

                exception
                    when others then
                        null;
                end;

                if l_str1 is not null then
                    l_str1 := l_str1
                              || ' , '
                              || l_str3;
                else
                    l_str1 := l_str3;
                end if;

                l_str2 := '';
            end if;

            if i = length(p_plan_fund_code) then
                begin
                    select
                        meaning
                    into l_str3
                    from
                        lookups
                    where
                            lookup_name = 'PLAN_ARRANGEMENT'
                        and lookup_code = l_str2;

                exception
                    when others then
                        null;
                end;

                l_str1 := l_str1
                          || ' , '
                          || l_str3;
            end if;

        end loop;

        return l_str1;
        declare
            p_batch_number  number;
            p_entrp_id      number;
            p_account_type  varchar2(200);
            p_user_id       varchar2(200);
            p_source        varchar2(200);
            x_error_status  varchar2(200);
            x_error_message varchar2(200);
        begin
            p_batch_number := null;
            p_entrp_id := null;
            p_account_type := null;
            p_user_id := null;
            p_source := null;
            x_error_status := null;
            x_error_message := null;
            pc_web_er_renewal.erisa_renewal_final_submit(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => p_account_type,
                p_user_id       => p_user_id,
                p_source        => p_source,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

        end;

    end plan_funding;
----------------------
 -- Added by Swamy for Ticket#8684 on 19/05/2020
 -- Procedure to load data from staging to base tables when SUBMIT buttion from online is pressed.
    procedure erisa_renewal_final_submit (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_account_type  in varchar2,
        p_user_id       in varchar2,
        p_source        in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        cursor cur_compliance is
        select
            record_id,
            entrp_id,
            no_off_ees,
            effective_date,
            state_of_org,
            fiscal_yr_end,
            type_of_entity,
            batch_number,
            bank_name,
            routing_number,
            bank_acc_num,
            bank_acc_type,
            error_message,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            remittance_flag,
            fees_payment_flag,
            salesrep_flag,
            salesrep_id,
            send_invoice,
            page2,
            page3_contact,
            page3_payment,
            entity_name_desc,
            org_eff_date,
            eff_date_sterling,
            no_of_eligible,
            affliated_flag,
            cntrl_grp_flag,
            page1_company,
            page1_plan,
            source,
            acct_payment_fees,
            submit_status,
            renewed_plan_id        -- Added by jaggi for Ticket#11533
            ,
            optional_fee_paid_by   -- Added by jaggi for Ticket#11533
        from
            online_compliance_staging
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

        cursor cur_comp_stage is
        select
            plan_id,
            entity_id,
            plan_name,
            plan_type,
            plan_number,
            policy_number,
            insurance_company_name,
            governing_state,
            plan_start_date,
            plan_end_date,
            self_funded_flag,
            conversion_flag,
            bill_cobra_premium_flag,
            coverage_terminate,
            age_rated_flag,
            carrier_contact_name,
            carrier_contact_email,
            carrier_phone_no,
            carrier_addr,
            ee_premium,
            ee_spouse_premium,
            ee_child_premium,
            ee_children_premium,
            ee_family_premium,
            spouse_premium,
            child_premium,
            spouse_child_premium,
            description,
            batch_number,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            ben_plan_id,
            error_message,
            fees_payment_flag,
            takeover_flag,
            ga_flag,
            ga_id,
            short_plan_yr_flag,
            flg_plan_name,
            grandfathered,
            self_administered,
            notes,
            subsidy_in_spd_apndx,
            clm_lang_in_spd,
            wrap_opt_flg,
            flg_pre_adop_pln,
            erissa_erap_doc_type,
            renewed_ben_plan_id  -- Added by Swamy for Ticket#10431(Renewal Resubmit)
        from
            compliance_plan_staging
        where
                batch_number = p_batch_number
            and entity_id = p_entrp_id;

        v_comp                 cur_compliance%rowtype;
        v_comp_plan            cur_comp_stage%rowtype;
        v_plan_fund_code       varchar2(500);
        v_acc_id               account.acc_id%type;
        v_acc_num              account.acc_num%type;
        l_new_ben_pln_id       ben_plan_enrollment_setup.ben_plan_id%type;
        x_return_status        varchar2(10);
        x_bank_acct_id         number;
        l_array                wwv_flow_global.vc_arr2;
        v_coll_bar_flag        erisa_aca_eligibility.collective_bargain_flag%type;
        v_phase                varchar2(100);
        v_wrap_plan_5500       erisa_aca_eligibility_stage.wrap_plan_5500%type;
        v_eligibility          varchar2(500);
        l_aff_entrp_id         number;
        l_ctrl_entrp_id        number;
        v_er_ee_contrib_lng    varchar2(500);
        v_code_name            varchar2(500);
        v_entity_type          varchar2(500);
        v_found                varchar2(1);
        x_quote_header_id      ar_quote_headers.quote_header_id%type;
        erreur exception;
        v_resubmit_flag        varchar2(1); -- Added by Swamy for Ticket#10431(Renewal Resubmit)
        l_renewed_by           varchar2(30); -- Added by Swamy for Ticket#10431(Renewal Resubmit)
        l_bank_exist_flag      varchar2(1) := 'N';
        l_entity_type          varchar2(30);
        l_broker_id            number;
        l_authorize_req_id     number;
        l_renewed_plan_id      number;              -- Added by jaggi for Ticket#11533
        l_plan_id              number;              -- Added by jaggi for Ticket#11533
        l_user_type            varchar2(20);        -- Added by jaggi for Ticket#11533
        l_ga_id                number;              -- Added by jaggi for Ticket#11533
        l_renewed_by_id        number;              -- Added by jaggi for Ticket#11533
        l_plan_start_date      date;                -- Added by jaggi for Ticket#11533
        l_prev_plan_start_date date;               -- Added by jaggi for Ticket#11533
        l_entity_id            number;              -- Added by Swamy for Ticket#11533
        l_acct_usage           varchar2(200);       -- Added by Swamy for Ticket#11533
        l_bank_count           number;              -- Added by Swamy for Ticket#11533
        l_bank_id              number;              -- Added by Swamy for Ticket#11533
        l_bank_acct_num        varchar2(50);
        lc_source              varchar2(5);
        l_return_status        varchar2(5);
        l_bank_status          varchar2(5);
        l_error_message        varchar2(500);
    begin
        pc_log.log_error('Erisa_Renewal_final_submit begin', 'P_Batch_Number := '
                                                             || p_batch_number
                                                             || ' P_Entrp_Id :='
                                                             || p_entrp_id);
        x_error_status := 'S';
        v_comp := null;
        v_plan_fund_code := null;
        v_acc_id := null;
        v_acc_num := null;
        open cur_compliance;
        fetch cur_compliance into v_comp;
        close cur_compliance;
        if v_comp.entrp_id is null then
            x_error_message := 'There is no data for Company Information';
            raise erreur;
        end if;
        v_acc_id := pc_entrp.get_acc_id(p_entrp_id);  -- Added by Swamy for Ticket#10431(Renewal Resubmit)
        v_resubmit_flag := pc_account.get_renewal_resubmit_flag(p_entrp_id);  -- Added by Swamy for Ticket#10431(Renewal Resubmit)

        -- For multiple submission case.
        -- For the first time submit this should always be null.
        -- For processing it will be INPROCESS state and for completed it will be in COMPLETED status
        if
            nvl(v_comp.submit_status, '*') <> '*'
            and v_resubmit_flag = 'N'
        then  -- Added AND Cond. by Swamy for Ticket#10431(Renewal Resubmit)
            x_error_message := 'This record is in '
                               || v_comp.submit_status
                               || ' status';
            raise erreur;
        end if;

        update online_compliance_staging
        set
            submit_status = 'INPROCESS'
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

        open cur_comp_stage;
        fetch cur_comp_stage into v_comp_plan;
        close cur_comp_stage;
        if v_comp_plan.plan_id is null then
            x_error_message := 'There is no data for Plan Setup Information/Arrangement Options';
            raise erreur;
        end if;

       -- v_acc_id  := pc_entrp.get_acc_id(p_entrp_id);  -- 10431 commented and moved on top
        v_acc_num := pc_account.get_acc_num_from_acc_id(v_acc_id);
        pc_log.log_error('Erisa_Renewal_final_submit begin', 'v_acc_id := '
                                                             || v_acc_id
                                                             || ' v_acc_num :='
                                                             || v_acc_num);
    -- Start Added by jaggi for Ticket#11533
        if
            nvl(v_comp.renewed_plan_id, 0) = 0
            and nvl(v_resubmit_flag, 'N') = 'Y'
        then
            for j in (
                select
                    max(plan_start_date) plan_start_date
                from
                    ben_plan_enrollment_setup
                where
                    acc_id = v_acc_id
            ) loop
                l_plan_start_date := j.plan_start_date;
            end loop;

            for j in (
                select
                    max(plan_start_date) plan_start_date
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = v_acc_id
                    and plan_start_date < l_plan_start_date
            ) loop
                l_prev_plan_start_date := j.plan_start_date;
            end loop;

            for k in (
                select
                    ben_plan_id
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = v_acc_id
                    and plan_start_date = l_prev_plan_start_date
            ) loop
                l_renewed_plan_id := k.ben_plan_id;
            end loop;

            v_comp.renewed_plan_id := l_renewed_plan_id;
        end if;

        pc_log.log_error('cobra_renewal_final_submit', 'v_resubmit_flag : '
                                                       || v_resubmit_flag
                                                       || 'V_Comp.renewed_plan_id :='
                                                       || v_comp.renewed_plan_id
                                                       || 'p_batch_number :='
                                                       || p_batch_number);

        if nvl(v_resubmit_flag, 'N') = 'Y' then   -- Added by jaggi for Ticket#11533
            pc_web_compliance.delete_resubmit_data(
                p_acc_id              => v_acc_id,
                p_entrp_id            => p_entrp_id,
                p_batch_number        => p_batch_number,
                p_renewed_ben_plan_id => v_comp.renewed_plan_id,
                p_ben_plan_id         => null,
                p_account_type        => 'ERISA_WRAP',
                p_eligibility_id      => null
            );

            update ben_plan_renewals
            set
                optional_fee_paid_by = v_comp.optional_fee_paid_by,
                pay_acct_fees = v_comp.acct_payment_fees
            where
                    renewed_plan_id = v_comp.renewed_plan_id
                and acc_id = v_acc_id;

        end if;
    -- end here jaggi

    -- -- Added by Swamy for Ticket#10431(Renewal Resubmit)
        if nvl(v_resubmit_flag, 'N') = 'Y' then
    --FOR I IN (SELECT renewal_resubmit_flag FROM account WHERE acc_id = v_acc_id AND renewal_resubmit_flag = 'Y') LOOP
            pc_web_compliance.delete_resubmit_data(
                p_acc_id              => v_acc_id,
                p_entrp_id            => p_entrp_id,
                p_batch_number        => p_batch_number,
                p_renewed_ben_plan_id => v_comp_plan.renewed_ben_plan_id,
                p_ben_plan_id         => v_comp_plan.ben_plan_id,
                p_account_type        => v_comp_plan.plan_type,
                p_eligibility_id      => null
            );

            l_new_ben_pln_id := v_comp_plan.renewed_ben_plan_id;
    --END LOOP;
        end if;

        pc_web_er_renewal.insrt_er_ben_plan_enrlmnt(
            p_ben_plan_id                 => v_comp_plan.ben_plan_id,
            p_min_election                => null,
            p_max_election                => null,
            p_new_plan_yr                 => v_comp_plan.plan_start_date,
            p_new_end_plan_yr             => v_comp_plan.plan_end_date     -- Added by Swamy for Ticket#9932 on 07/06/2021
            ,
            p_runout_prd                  => null,
            p_runout_trm                  => null,
            p_grace                       => null,
            p_grace_days                  => null,
            p_rollover                    => null,
            p_funding_options             => null,
            p_non_discm                   => null,
            p_new_hire                    => null,
            p_eob_required                => null,
            p_enrlmnt_start               => null,
            p_enrlmnt_endt                => null,
            p_plan_docs                   => null,
            p_user_id                     => p_user_id,
            p_post_tax                    => null,
            p_pay_acct_fees               => v_comp.acct_payment_fees,
            p_update_limit_match_irs_flag => null,
            p_source                      => p_source,
            p_batch_number                => p_batch_number -- Added by Swamy for Ticket#10431(Renewal Resubmit)
            ,
            p_new_ben_pln_id              => l_new_ben_pln_id,
            x_return_status               => x_return_status,
            x_error_message               => x_error_message
        );

        if nvl(x_return_status, 'S') = 'E' then
            v_phase := 'Error at Phase 1';
            raise erreur;
        end if;

        update enterprise
        set
            entity_name_desc = v_comp.entity_name_desc
        where
            entrp_id = p_entrp_id;

            -- Added by Swamy for Ticket#10431(Renewal Resubmit)
        update compliance_plan_staging
        set
            renewed_ben_plan_id = nvl(renewed_ben_plan_id, l_new_ben_pln_id)
        where
                batch_number = p_batch_number
            and entity_id = p_entrp_id;

        pc_log.log_error('Erisa_Renewal_final_submit after phase 1 ', 'l_NEW_BEN_PLN_ID := '
                                                                      || l_new_ben_pln_id
                                                                      || ' v_acc_num :='
                                                                      || v_acc_num
                                                                      || ' v_comp_plan.ben_plan_id :='
                                                                      || v_comp_plan.ben_plan_id);
  -- inserting into benefit codes table
        for j in (
            select
                seq_id,
                entity_id,
                benefit_code_id,
                benefit_code_name,
                status,
                batch_number,
                creation_date,
                created_by,
                last_updated_by,
                description,
                entity_type,
                er_cont_pref,
                ee_cont_pref,
                eligibility,
                er_ee_contrib_lng,
                refer_to_doc,
                eligibility_refer_to_doc,
                flg_block    -- Added by Swamy for Ticket#9304
            from
                benefit_codes_stage
            where
                    batch_number = p_batch_number
                and entity_id = v_comp_plan.ben_plan_id
                and flg_block = '2'
        ) loop
            v_eligibility := null;
            v_er_ee_contrib_lng := null;
            v_code_name := null;
            if nvl(j.eligibility, '*') <> '*' then
                v_eligibility := nvl(
                    pc_lookups.get_meaning(j.eligibility, 'ELIGIBILITY_OPTIONS'),
                    pc_lookups.get_meaning(j.eligibility, 'ELIGIBILITY_OPTIONS_OTHER')
                );
       -- Added by Joshi 7791
                if v_eligibility is null then
                    v_eligibility := pc_lookups.get_meaning(j.eligibility, 'ELIGIBILITY_OPTIONS_OTHER_REF');
                end if;

            end if;

            if nvl(j.er_ee_contrib_lng, '*') <> '*' then
                v_er_ee_contrib_lng := pc_lookups.get_meaning(j.er_ee_contrib_lng, 'ER_EE_CONTRIB_LNG');
            end if;

            if j.benefit_code_name = 'OTHER' then
                v_code_name := j.benefit_code_name
                               || '('
                               || j.description
                               || ')';
            else
                v_code_name := j.benefit_code_name;
            end if;

            insert into benefit_codes (
                benefit_code_id,
                benefit_code_name,
                entity_id,
                entity_type,
                description,
                er_cont_pref,
                ee_cont_pref,
                eligibility,
                er_ee_contrib_lng,
                refer_to_doc,
                eligibility_refer_to_doc,
                eligibility_code         -- Added by Swamy for Ticket#9304
                ,
                er_ee_contrib_lng_code   -- Added by Swamy for Ticket#9304
                ,
                flg_block               -- Added by Swamy for Ticket#9304
                ,
                creation_date,
                created_by
            ) values ( benefit_code_seq.nextval,
                       v_code_name,
                       l_new_ben_pln_id,
                       j.entity_type,
                       j.description,
                       j.er_cont_pref,
                       j.ee_cont_pref,
                       v_eligibility,
                       v_er_ee_contrib_lng,
                       j.refer_to_doc,
                       j.eligibility_refer_to_doc,
                       j.eligibility           -- Added by Swamy for Ticket#9304
                       ,
                       j.er_ee_contrib_lng     -- Added by Swamy for Ticket#9304
                       ,
                       j.flg_block                -- Added by Swamy for Ticket#9304
                       ,
                       sysdate,
                       p_user_id );

        end loop;

        pc_log.log_error('Erisa_Renewal_final_submit insert ben_codes for flg_block 1,3 ', 'P_Batch_Number := '
                                                                                           || p_batch_number
                                                                                           || 'v_comp_plan.BEN_PLAN_ID :='
                                                                                           || v_comp_plan.ben_plan_id);

        pc_log.log_error('PC_WEB_ER_RENEWAL.Erisa_Renewal_final_submit Inserting the records into Benefit_Codes Table for Flg_Block 1 and flg_block 3'
        , 'X_Error_Status := ' || x_error_status);
        for j in (
            select distinct
                benefit_code_name,
                entity_id,
                benefit_code_id,
                status,
                batch_number,
                creation_date,
                created_by,
                last_updated_by,
                description,
                entity_type,
                er_cont_pref,
                ee_cont_pref,
                eligibility,
                er_ee_contrib_lng,
                refer_to_doc,
                eligibility_refer_to_doc,
                flg_block      -- Added by Swamy for Ticket#9304
            from
                benefit_codes_stage
            where
                    batch_number = p_batch_number
                and entity_id = v_comp_plan.ben_plan_id
                and flg_block in ( '1', '3' )
        )--cur_benefit_codes
         loop
      /*-- During Enrollment,Some Of The Items Are Repeated In Three Blocks(Subsidiary Contracts(Block 1),Welfare Benefit Plans(Block 2),Claims Language (Block 3)),
      -- All The Duplicate Records Are Stored In Session Table.(Beneft_Codes_Stage). But Insertion Into Base Table(Benefit Codes) Only Unique Record Should Be Inserted.
      -- Hence We Are First Inserting All The Records With Flg_Block = 2, And Then Check For Records Of Flg_Block 1 And 3 With Already Inserted Record Of Flg_Block 1. If Its Already Inserted, Then Continue,Else The Record Is Inserted.
      v_found := 'F';
      FOR M IN
      (SELECT Benefit_Code_Name
         FROM Benefit_Codes_Stage
        WHERE Batch_Number       = P_Batch_Number
          AND Entity_Id          = v_comp_plan.BEN_PLAN_ID
          AND Flg_Block          = '2'
          AND Benefit_Code_Name  = J.Benefit_Code_Name
          AND Benefit_Code_Name  <> 'OTHER'
      )
      LOOP
        V_Found := 'T';
        EXIT;
      END LOOP;
      V_Code_Name   := NULL;
      V_Entity_Type := NULL;
      IF V_Found  = 'T' THEN
        CONTINUE;
      END IF;
	  */    -- Commented by Swamy for Ticket#9304

            v_code_name := null;
            v_entity_type := null;
	  -- Below is defied as per the code in pc_web_compliance.UPSERT_ERISA_BEN_CODES
            if nvl(j.eligibility, '*') = '*' then
                v_entity_type := 'BEN_PLAN_RENEWAL';
            else
                v_entity_type := 'SUBSIDIARY_CONTRACT';
            end if;

            if j.benefit_code_name = 'OTHER' then
                v_code_name := j.benefit_code_name
                               || '('
                               || j.description
                               || ')';
            else
                v_code_name := j.benefit_code_name;
            end if;

            insert into benefit_codes (
                benefit_code_id,
                benefit_code_name,
                entity_id,
                entity_type,
                description,
                er_cont_pref,
                ee_cont_pref,
                eligibility,
                er_ee_contrib_lng,
                refer_to_doc,
                eligibility_refer_to_doc,
                eligibility_code         -- Added by Swamy for Ticket#9304
                ,
                er_ee_contrib_lng_code   -- Added by Swamy for Ticket#9304
                ,
                flg_block                -- Added by Swamy for Ticket#9304
                ,
                creation_date,
                created_by
            ) values ( benefit_code_seq.nextval,
                       v_code_name,
                       l_new_ben_pln_id,
                       v_entity_type,
                       j.description,
                       j.er_cont_pref,
                       j.ee_cont_pref,
                       j.eligibility,
                       j.er_ee_contrib_lng,
                       j.refer_to_doc,
                       j.eligibility_refer_to_doc -- added by Joshi for 7791
                       ,
                       j.eligibility           -- Added by Swamy for Ticket#9304
                       ,
                       j.er_ee_contrib_lng     -- Added by Swamy for Ticket#9304
                       ,
                       j.flg_block             -- Added by Swamy for Ticket#9304
                       ,
                       sysdate,
                       p_user_id );

        end loop;

        pc_log.log_error('Erisa_Renewal_final_submit insert plan notices ', 'P_Batch_Number := '
                                                                            || p_batch_number
                                                                            || ' P_Entrp_Id :='
                                                                            || p_entrp_id);
    --Plan Notices:
        for i in (
            select
                notice_type,
                flg_no_notice,
                flg_addition
            from
                plan_notices_stage
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and notice_type is not null
        ) loop
		  -- In Erisa Notice_Type The Functionality Of 5500 Is Not Used. In Coding It Is Used As 5500 During Insertion In Staging Table To Get The Value Of Flg_No_Notice And Flg_Addition
		  -- This Is Used During Retrival, As The Query For Retrival Is A Join From Lookup Table With Lookup_Code As 'Plan_Notice', Hence During Insertion From Staging To Base Tables
		  -- We Are Not Inserting The Record With Notice_Type 5500.
            if i.notice_type = '5500' then
                if nvl(i.flg_no_notice, '*') = 'N' then  -- Start Added by swamy for Ticket#6681
                    if nvl(v_plan_fund_code, '*') = '*' then
                        v_plan_fund_code := 'NO_NOTICE';
                    else
                        v_plan_fund_code := v_plan_fund_code
                                            || ':'
                                            || 'NO_NOTICE';
                    end if;
                end if;      -- End Of Addition by swamy for Ticket#6681
                continue;
            end if;

            if nvl(v_plan_fund_code, '*') = '*' then
                v_plan_fund_code := i.notice_type;
            else
                v_plan_fund_code := v_plan_fund_code
                                    || ':'
                                    || i.notice_type;
            end if;

        end loop;

        l_array := apex_util.string_to_table(v_plan_fund_code, ':');
        if l_array.first is not null then
            for i in l_array.first..l_array.last loop
                pc_compliance.insert_plan_notices(
                    p_ben_plan_id => l_new_ben_pln_id,
                    p_report_type => l_array(i),
                    p_user_id     => p_user_id
                );
            end loop;
        end if;

        for k in (
            select
                ben_plan_id,
                aca_ale_flag,
                variable_hour_flag,
                irs_lbm_flag,
                intl_msrmnt_period,
                intl_msrmnt_start_date,
                intl_admn_period,
                stblty_period,
                fte_hrs,
                fte_salary_msmrt_period,
                fte_hourly_msmrt_period,
                fte_other_msmrt_period,
                fte_look_back,
                fte_lkp_salary_msmrt_period,
                fte_lkp_hourly_msmrt_period,
                fte_lkp_other_msmrt_period,
                msrmnt_period,
                msrmnt_start_date,
                msrmnt_end_date,
                stblt_start_date,
                stblt_period,
                stblt_end_date,
                fte_same_period_resume_date,
                fte_diff_period_resume_date,
                admn_start_date,
                admn_period,
                admn_end_date,
                mnthl_msrmnt_flag,
                same_prd_bnft_start_date,
                new_prd_bnft_start_date,
                entrp_id,
                fte_same_period_select,
                fte_diff_period_select,
                special_inst,
                collective_bargain_flag,
                wrap_plan_5500,
                fte_other_ee_detail,
                fte_lkp_other_ee_detail,
                define_intl_msrmnt_period
            from
                erisa_aca_eligibility_stage
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
        ) loop

    --Create ACA eligibility :
            pc_web_er_renewal.create_aca_eligibility(
                p_ben_plan_id                 => l_new_ben_pln_id,
                p_aca_ale_flag                => k.aca_ale_flag,
                p_variable_hour_flag          => k.variable_hour_flag,
                p_irs_lbm_flag                => k.irs_lbm_flag,
                p_intl_msrmnt_period          => k.intl_msrmnt_period,
                p_intl_msrmnt_start_date      => k.intl_msrmnt_start_date,
                p_intl_admn_period            => k.intl_admn_period,
                p_stblty_period               => k.stblty_period,
                p_fte_hrs                     => k.fte_hrs,
                p_fte_salary_msmrt_period     => k.fte_salary_msmrt_period,
                p_fte_hourly_msmrt_period     => k.fte_hourly_msmrt_period,
                p_fte_other_msmrt_period      => k.fte_other_msmrt_period,
                p_fte_other_ee_name           => k.fte_other_ee_detail,
                p_fte_look_back               => k.fte_look_back,
                p_fte_lkp_salary_msmrt_period => k.fte_lkp_salary_msmrt_period,
                p_fte_lkp_hourly_msmrt_period => k.fte_lkp_hourly_msmrt_period,
                p_fte_lkp_other_msmrt_period  => k.fte_lkp_other_msmrt_period,
                p_fte_lkp_other_ee_name       => k.fte_lkp_other_ee_detail,
                p_msrmnt_period               => k.msrmnt_period,
                p_msrmnt_start_date           => k.msrmnt_start_date,
                p_msrmnt_end_date             => k.msrmnt_end_date,
                p_stblt_start_date            => k.stblt_start_date,
                p_stblt_period                => k.stblt_period,
                p_stblt_end_date              => k.stblt_end_date,
                p_fte_same_period_resume_date => k.fte_same_period_resume_date,
                p_fte_diff_period_resume_date => k.fte_diff_period_resume_date,
                p_admn_start_date             => k.admn_start_date,
                p_admn_period                 => k.admn_period,
                p_admn_end_date               => k.admn_end_date,
                p_mnthl_msrmnt_flag           => k.mnthl_msrmnt_flag,
                p_same_prd_bnft_start_date    => k.same_prd_bnft_start_date,
                p_new_prd_bnft_start_date     => k.new_prd_bnft_start_date,
                p_user_id                     => p_user_id,
                p_entrp_id                    => k.entrp_id,
                p_fte_same_period_select      => k.fte_same_period_select,
                p_fte_diff_period_select      => k.fte_diff_period_select,
                p_define_intl_msrmnt_period   => k.define_intl_msrmnt_period,
                x_error_status                => x_error_status,
                x_error_message               => x_error_message
            );

            if nvl(x_error_status, 'S') = 'E' then
                v_phase := 'Error at Phase 3';
                raise erreur;
            end if;

        --Special Instructions :
            pc_utility.insert_notes(
                p_entity_id     => l_new_ben_pln_id,
                p_entity_type   => 'BEN_PLAN_ENROLLMENT_SETUP',
                p_description   => k.special_inst,
                p_user_id       => p_user_id,
                p_creation_date => sysdate,
                p_pers_id       => null,
                p_acc_id        => v_acc_id,
                p_entrp_id      => p_entrp_id,
                p_action        => 'SPECIAL_INSTRUCTIONS'
            );

            v_coll_bar_flag := k.collective_bargain_flag;
            v_wrap_plan_5500 := k.wrap_plan_5500;
        end loop;

        pc_log.log_error('Erisa_Renewal_final_submit after aca eligibility inst to bank ', 'fees_payment_flag := '
                                                                                           || v_comp.fees_payment_flag
                                                                                           || ' P_Entrp_Id :='
                                                                                           || p_entrp_id);

	/*
    IF v_Comp.fees_payment_flag = 'ACH' THEN
       X_Bank_Acct_Id := NULL;

       -- Added by Swamy for Ticket#11533
       l_acct_usage := 'INVOICE';
       l_bank_count := 0;

        -- Annual bank details
        IF v_Comp.bank_name IS NOT NULL THEN
            IF UPPER(v_Comp.acct_payment_fees)= 'EMPLOYER'  THEN
                l_entity_id := v_acc_id;
                l_entity_type := 'ACCOUNT';
            ELSIF UPPER(v_Comp.acct_payment_fees) = 'BROKER'  THEN
                l_entity_id := pc_account.get_broker_id(v_acc_id);
                l_entity_type := 'BROKER';
            ELSIF UPPER( v_Comp.acct_payment_fees) = 'GA'  THEN
                l_entity_id := pc_account.get_ga_id(v_acc_id);
                l_entity_type := 'GA';
            END IF;

            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_entity_id: ',l_entity_id);
            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_entity_type',l_entity_type);
            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_acct_usage l',l_acct_usage);

             SELECT COUNT(*) INTO l_bank_count
               FROM bank_Accounts
              WHERE bank_routing_num = v_Comp.routing_number
                AND bank_acct_num    = v_Comp.bank_acc_num
                AND bank_name        = v_Comp.bank_name
                AND status           = 'A'
                AND bank_account_usage = l_acct_usage
                AND entity_id        = l_entity_id
                AND entity_type      = l_entity_type ;

            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_count l',l_bank_count);

              IF l_bank_count = 0 THEN
                  -- fee bank details
                  pc_user_bank_acct.insert_bank_account(
                                     p_entity_id          => l_entity_id
                                    ,p_entity_type        => l_entity_type
                                    ,p_display_name       => v_Comp.bank_name
                                    ,p_bank_acct_type     => v_Comp.bank_acc_type
                                    ,p_bank_routing_num   => v_Comp.routing_number
                                    ,p_bank_acct_num      => v_Comp.bank_acc_num
                                    ,p_bank_name          => v_Comp.bank_name
                                    ,p_bank_account_usage => NVL(l_acct_usage,'INVOICE')
                                    ,p_user_id            => p_user_id
                                    ,x_bank_acct_id       => X_Bank_Acct_Id
                                    ,x_return_status      => x_error_status
                                    ,x_error_message      => x_error_message);

                               IF NVL(x_error_status,'S') = 'E' THEN
                                  x_error_message := (x_error_message || 'ERROR in cobra_renewal_final_submit after calling insert_bank_account');
                                  RAISE ERREUR;
                               END IF;

                 ELSE
                    FOR   B IN ( SELECT bank_acct_id
                                   FROM bank_Accounts
                                  WHERE bank_routing_num = v_Comp.routing_number
                                    AND bank_acct_num    = v_Comp.bank_acc_num
                                    AND bank_name        = v_Comp.bank_name
                                    AND status           = 'A'
                                    AND bank_account_usage = l_acct_usage
                                    AND entity_id        = l_entity_id
                                    AND entity_type      = l_entity_type
                                )
                    LOOP
                            l_bank_id := b.bank_Acct_id ;
                    END LOOP;
                    pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_id l',l_bank_id);
                END IF;
                X_Bank_Acct_Id   := l_bank_id;
        END IF;  
    END IF;
    */

	-- Added by Swamy for Ticket#12698
        if upper(v_comp.fees_payment_flag) = 'ACH' then
            l_bank_acct_num := null;
            x_bank_acct_id := null;
            l_bank_id := null;         
	  /*Create Bank Info */
            if p_source = 'ENROLLMENT' then
                lc_source := 'E';
            else
                lc_source := 'R';
            end if;

            pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main.. calling populate_bank_Accounts', 'In Proc lc_source' || lc_source
            );
            pc_giact_validations.populate_bank_accounts(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_product_type  => 'ERISA_WRAP',
                p_user_id       => p_user_id,
                p_source        => lc_source,
                x_bank_acct_id  => l_bank_id,
                x_bank_status   => l_bank_status,
                x_return_status => l_return_status,
                x_error_message => l_error_message
            );

            pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main.. after calling populate_bank_Accounts', 'In Proc l_bank_id'
                                                                                                              || l_bank_id
                                                                                                              || 'l_bank_status :='
                                                                                                              || l_bank_status
                                                                                                              || 'l_return_status :='
                                                                                                              || l_return_status
                                                                                                              || ' l_error_message :='
                                                                                                              || l_error_message);

            if l_return_status <> 'S' then
                raise erreur;
            end if;
            l_bank_acct_num := pc_user_bank_acct.get_bank_acct_num(l_bank_id);
            x_bank_acct_id := l_bank_id;
            pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main after calling populate_bank_Accounts **1', 'In Proc l_bank_acct_num'
                                                                                                                || l_bank_acct_num
                                                                                                                || ' v_comp.record_id :='
                                                                                                                || v_comp.record_id);

            update online_compliance_staging
            set
                bank_acct_id = l_bank_id,
                bank_acc_num = l_bank_acct_num
            where
                record_id = v_comp.record_id;

        end if;

        pc_log.log_error('Erisa_Renewal_final_submit caling CREATE_EMP_PLAN_CONTACTS ', 'P_Batch_Number := '
                                                                                        || p_batch_number
                                                                                        || ' P_Entrp_Id :='
                                                                                        || p_entrp_id);
        for v_plan in (
            select
                admin_type,
                plan_admin_name,
                contact_type,
                contact_name,
                phone_num,
                email,
                address1,
                address2,
                city,
                state,
                zip_code,
                plan_agent,
                description,
                agent_name,
                legal_agent_contact_type,
                legal_agent_contact,
                legal_agent_phone,
                legal_agent_email,
                trust_fund,
                trustee_name,
                trustee_contact_type,
                trustee_contact_name,
                trustee_contact_phone,
                trustee_contact_email
            from
                plan_employer_contacts_stage
            where
                    batch_number = p_batch_number
                and entity_id = p_entrp_id
        ) loop
            pc_log.log_error('PC_WEB_ER_RENEWAL.Erisa_Renewal_final_submit CREATE_EMP_PLAN_CONTACTS', 'V_Plan.Email := '
                                                                                                      || v_plan.email
                                                                                                      || ' V_Plan.Admin_Type :='
                                                                                                      || v_plan.admin_type);

         --Emp Plan contact :
            pc_employer_enroll.create_emp_plan_contacts(
                p_admin_type               => v_plan.admin_type,
                p_plan_admin_name          => v_plan.plan_admin_name,
                p_contact_type             => v_plan.contact_type,
                p_contact_name             => v_plan.contact_name,
                p_phone_num                => v_plan.phone_num,
                p_email                    => v_plan.email,
                p_address1                 => v_plan.address1,
                p_address2                 => v_plan.address2,
                p_city                     => v_plan.city,
                p_state                    => v_plan.state,
                p_zip_code                 => v_plan.zip_code,
                p_plan_agent               => v_plan.plan_agent,
                p_description              => v_plan.description,
                p_agent_name               => v_plan.agent_name,
                p_legal_agent_contact_type => v_plan.legal_agent_contact_type,
                p_legal_agent_contact      => v_plan.legal_agent_contact,
                p_legal_agent_phone        => v_plan.legal_agent_phone,
                p_legal_agent_email        => v_plan.legal_agent_email,
                p_trust_fund               => v_plan.trust_fund,
                p_trustee_name             => v_plan.trustee_name,
                p_trustee_contact_type     => v_plan.trustee_contact_type,
                p_trustee_contact_name     => v_plan.trustee_contact_name,
                p_trustee_contact_phone    => v_plan.trustee_contact_phone,
                p_trustee_contact_email    => v_plan.trustee_contact_email,
                p_user_id                  => p_user_id,
                p_entrp_id                 => l_new_ben_pln_id,
                p_batch_number             => p_batch_number,
                x_error_status             => x_error_status,
                x_error_message            => x_error_message
            );

            pc_log.log_error('PC_WEB_ER_RENEWAL.Erisa_Renewal_final_submit After calling CREATE_EMP_PLAN_CONTACTS', 'X_Error_Status := '
                                                                                                                    || x_error_status
                                                                                                                    || ' X_Error_Message :='
                                                                                                                    || x_error_message
                                                                                                                    );
            if nvl(x_error_status, 'S') = 'E' then
                v_phase := 'Error at Phase 5';
                raise erreur;
            end if;

        end loop;

        pc_log.log_error('Erisa_Renewal_final_submit caling INSRT_AR_QUOTE_HEADERS ', 'P_Batch_Number := '
                                                                                      || p_batch_number
                                                                                      || ' P_Entrp_Id :='
                                                                                      || p_entrp_id);
        for l in (
            select
                quote_name,
                quote_number,
                total_quote_price,
                quote_date,
                payment_method,
                entrp_id,
                bank_acct_id,
                ben_plan_id,
                quote_source,
                billing_frequency,
                quote_header_id
            from
                ar_quote_headers_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
        ) loop
        --renewal service head(invoice) :
            pc_web_compliance.insrt_ar_quote_headers(
                p_quote_name        => l.quote_name,
                p_quote_number      => l.quote_number,
                p_total_quote_price => l.total_quote_price,
                p_quote_date        => to_char(sysdate, 'MM/DD/RRRR'),
                p_payment_method    => upper(v_comp.fees_payment_flag),
                p_entrp_id          => l.entrp_id,
                p_bank_acct_id      => x_bank_acct_id,
                p_ben_plan_id       => l_new_ben_pln_id,
                p_user_id           => p_user_id,
                p_quote_source      => 'ONLINE',
                p_product           => 'ERISA_WRAP',
                p_billing_frequency => null,
                x_quote_header_id   => x_quote_header_id,
                x_return_status     => x_return_status,
                x_error_message     => x_error_message
            );

            if nvl(x_return_status, 'S') = 'E' then
                v_phase := 'Error at Phase 6';
                raise erreur;
            end if;

            pc_log.log_error('Erisa_Renewal_final_submit UPDATE ar_quote_headers_staging  ', 'x_quote_header_id := ' || x_quote_header_id
            );
            update ar_quote_headers_staging
            set
                quote_header_id = x_quote_header_id
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and quote_header_id = l.quote_header_id;

            update ar_quote_lines_staging
            set
                quote_header_id = x_quote_header_id
            where
                    batch_number = p_batch_number
                and quote_header_id = l.quote_header_id;

        end loop;

        pc_log.log_error('Erisa_Renewal_final_submit INSRT_AR_QUOTE_LINES  ', 'p_batch_number := '
                                                                              || p_batch_number
                                                                              || 'p_entrp_id :='
                                                                              || p_entrp_id);
        for m in (
            select
                b.quote_header_id,
                a.rate_plan_id,
                a.rate_plan_detail_id,
                a.line_list_price,
                a.notes
            from
                ar_quote_lines_staging   a,
                ar_quote_headers_staging b
            where
                    a.batch_number = b.batch_number
                and a.quote_header_id = b.quote_header_id
                and b.batch_number = p_batch_number
                and b.entrp_id = p_entrp_id
        ) loop

         -- renewal service line :
            pc_web_compliance.insrt_ar_quote_lines(
                p_quote_header_id     => m.quote_header_id,
                p_rate_plan_id        => m.rate_plan_id,
                p_rate_plan_detail_id => m.rate_plan_detail_id,
                p_line_list_price     => m.line_list_price,
                p_notes               => m.notes,
                p_user_id             => p_user_id,
                x_return_status       => x_return_status,
                x_error_message       => x_error_message
            );

            if nvl(x_return_status, 'S') = 'E' then
                v_phase := 'Error at Phase 7';
                raise erreur;
            end if;

        end loop;

        pc_log.log_error('Erisa_Renewal_final_submit calling pc_web_compliance.UPSERT_ERISA_STAGE  ', 'l_NEW_BEN_PLN_ID := '
                                                                                                      || l_new_ben_pln_id
                                                                                                      || 'v_Coll_Bar_Flag :='
                                                                                                      || v_coll_bar_flag);
 --Renewal Info :
        pc_web_compliance.upsert_erisa_stage(
            p_entrp_id             => p_entrp_id,
            p_acc_id               => v_acc_id,
            p_ben_plan_id          => l_new_ben_pln_id,
            p_entity_type          => v_comp.type_of_entity,
            p_grandfathered        => v_comp_plan.grandfathered,
            p_clm_lang_in_spd      => v_comp_plan.clm_lang_in_spd,
            p_administered         => v_comp_plan.self_administered,
            p_subsidy_in_spd_apndx => v_comp_plan.subsidy_in_spd_apndx,
            p_col_bargain          => v_coll_bar_flag,
            p_ben_plan_number      => v_comp_plan.plan_number,
            p_no_of_eligible       => v_comp.no_of_eligible,
            p_no_of_employees      => v_comp.no_off_ees,
            p_affiliated_er        => v_comp.affliated_flag,
            p_controlled_group     => v_comp.cntrl_grp_flag,
            p_note                 => v_comp_plan.notes,
            p_bank_acct_num        => v_comp.bank_acc_num,
            p_plan_include         => null,
            p_form55_opted         => v_wrap_plan_5500,
            p_erissa_erap_doc_type => v_comp_plan.erissa_erap_doc_type,
            p_fiscal_end_date      => v_comp.fiscal_yr_end,
            p_user_id              => p_user_id,
            p_ben_plan_name        => v_comp_plan.plan_name           -- added by jaggi #9905
            ,
            x_return_status        => x_return_status,
            x_error_message        => x_error_message
        );

        if nvl(x_return_status, 'S') = 'E' then
            v_phase := 'Error at Phase 8';
            raise erreur;
        end if;

        pc_log.log_error('Erisa_Renewal_final_submit inst enterprise census ', 'v_comp.No_Off_Ees := '
                                                                               || v_comp.no_off_ees
                                                                               || 'v_comp.no_of_eligible :='
                                                                               || v_comp.no_of_eligible);

        if nvl(v_comp.no_off_ees, 0) <> 0 then
            insert into enterprise_census (
                entity_id,
                entity_type,
                census_code,
                census_numbers,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                ben_plan_id
            ) values ( p_entrp_id,
                       'ENTERPRISE',
                       'NO_OF_EMPLOYEES',
                       v_comp.no_off_ees,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       l_new_ben_pln_id    -- Replaced NUll with l_NEW_BEN_PLN_ID by Swamy for Ticket#9304
                        );

        end if;

        if nvl(v_comp.no_of_eligible, 0) <> 0 then
            insert into enterprise_census (
                entity_id,
                entity_type,
                census_code,
                census_numbers,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                ben_plan_id
            ) values ( p_entrp_id,
                       'ENTERPRISE',
                       'NO_OF_ELIGIBLE',
                       v_comp.no_of_eligible,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       l_new_ben_pln_id    -- Replaced NUll with l_NEW_BEN_PLN_ID by Swamy for Ticket#9304
                        );

        end if;

        pc_log.log_error('PC_WEB_ER_RENEWAL.Erisa_Renewal_final_submit', 'Census Data updated v_resubmit_flag :=' || v_resubmit_flag)
        ;
     /*Creating Affliated Employer */
        for x in (
            select
                name
            from
                enterprise_staging
            where
                    en_code = '10'
                and batch_number = p_batch_number
            order by
                entrp_stg_id
        ) loop
   -- IF NVL(v_resubmit_flag,'N')  = 'N' THEN   -- Added by Swamy for Ticket#10431
            insert into enterprise (
                entrp_id,
                en_code,
                name,
                created_by,
                creation_date
            ) values ( entrp_seq.nextval,
                       10,
                       x.name,
                       p_user_id,
                       sysdate ) returning entrp_id into l_aff_entrp_id;

            pc_log.log_error('PC_WEB_ER_RENEWAL.Erisa_Renewal_final_submit', 'Census Data updated update Create_enterprise_relation :=' || x.name
            );
            pc_employer_enroll.create_enterprise_relation(
                p_entrp_id      => p_entrp_id        ---Original ER(GPOP)
                ,
                p_entity_id     => l_aff_entrp_id   ---Affliated ER
                ,
                p_entity_type   => 'ENTERPRISE',
                p_relat_type    => 'AFFILIATED_ER',
                p_user_id       => p_user_id,
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );
  /* ELSE
        for j in (select ENTITY_ID,RELATIONSHIP_TYPE from ENTRP_RELATIONSHIPS where entrp_id = p_entrp_id and entity_type = 'ENTERPRISE' and RELATIONSHIP_TYPE = 'AFFILIATED_ER') loop
            PC_log.log_error('PC_WEB_ER_RENEWAL.Erisa_Renewal_final_submit','Census Data updated update enterprise :='||x.NAME);

          update enterprise set name = x.NAME where entrp_id = j.entity_id and EN_CODE = 10;
        end loop;
   END IF;*/
        end loop;

    /*Control Group Data */
        for i in (
            select
                name
            from
                enterprise_staging
            where
                    en_code = '11'
                and batch_number = p_batch_number
            order by
                entrp_stg_id
        ) loop
   -- IF NVL(v_resubmit_flag,'N')  = 'N' THEN   -- Added by Swamy for Ticket#10431
            insert into enterprise (
                entrp_id,
                en_code,
                name,
                created_by,
                creation_date
            ) values ( entrp_seq.nextval,
                       11,
                       i.name,
                       p_user_id,
                       sysdate ) returning entrp_id into l_ctrl_entrp_id;

            pc_employer_enroll.create_enterprise_relation(
                p_entrp_id      => p_entrp_id        ---Original ER(GPOP)
                ,
                p_entity_id     => l_ctrl_entrp_id  ---Cntrl Grp ER
                ,
                p_entity_type   => 'ENTERPRISE',
                p_relat_type    => 'CONTROLLED_GROUP',
                p_user_id       => p_user_id,
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );
   /*  ELSE
        for j in (select ENTITY_ID,RELATIONSHIP_TYPE from ENTRP_RELATIONSHIPS where entrp_id = p_entrp_id and entity_type = 'ENTERPRISE' and RELATIONSHIP_TYPE = 'CONTROLLED_GROUP') loop
         update enterprise set name = i.NAME where entrp_id = j.entity_id and EN_CODE = 11;
        end loop;
     END IF;*/
        end loop;

        pc_log.log_error('Erisa_Renewal_final_submit calling Update_Contact_Info ', 'P_Account_Type := ' || p_account_type);
        for i in (
            select
                contact_id,
                first_name,
                email,
                user_id,
                creation_date,
                updated,
                entity_id,
                account_type,
                contact_type,
                send_invoice,
                entity_type,
                ref_entity_id,
                ref_entity_type,
                phone_num,
                contact_fax,
                job_title,
                lic_number
            from
                contact_leads a
            where
                    account_type = p_account_type
                and not exists (
                    select
                        1
                    from
                        contact b
                    where
                        a.contact_id = b.contact_id
                )
                and entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and contact_flg = 'Y'     -- Only save the details of the contact who's value is selected during online renewal. Staging table contains data for both selected and non selected contacts.
        ) --Cur_Contacts
         loop
            if nvl(i.lic_number, '*') = '*' then
                pc_log.log_error('PC_WEB_ER_RENEWAL.Erisa_Renewal_final_submit calling Update_Contact_Info', 'I.Contact_Id := '
                                                                                                             || i.contact_id
                                                                                                             || ' P_Entrp_Id :='
                                                                                                             || p_entrp_id);

                pc_employer_enroll.update_contact_info(
                    p_contact_id      => i.contact_id,
                    p_entrp_id        => p_entrp_id,
                    p_first_name      => i.first_name,
                    p_email           => i.email,
                    p_account_type    => i.account_type,
                    p_contact_type    => i.contact_type,
                    p_user_id         => p_user_id,
                    p_ref_entity_id   => i.ref_entity_id,
                    p_ref_entity_type => i.ref_entity_type,
                    p_send_invoice    => i.send_invoice,
                    p_status          => 'A',
                    p_phone_num       => i.phone_num,
                    p_fax_no          => i.contact_fax,
                    p_job_title       => i.job_title,
                    x_return_status   => x_error_status,
                    x_error_message   => x_error_message
                );

                pc_log.log_error('PC_WEB_ER_RENEWAL.Erisa_Renewal_final_submit After calling Update_Contact_Info', 'X_Error_Status := '
                                                                                                                   || x_error_status
                                                                                                                   || ' X_Error_Message :='
                                                                                                                   || x_error_message
                                                                                                                   );
                if nvl(x_error_status, 'S') = 'E' then
                    v_phase := 'Error at Phase 9';
                    raise erreur;
                end if;

            elsif nvl(i.lic_number, '*') <> '*' then
                 -- Agent Info :
                pc_broker.insert_sales_team_leads(
                    p_first_name      => null,
                    p_last_name       => null,
                    p_license         => i.lic_number,
                    p_agency_name     => i.first_name,
                    p_tax_id          => null,
                    p_gender          => null,
                    p_address         => null,
                    p_city            => null,
                    p_state           => null,
                    p_zip             => null,
                    p_phone1          => null,
                    p_phone2          => null,
                    p_email           => i.email,
                    p_entrp_id        => p_entrp_id,
                    p_ref_entity_id   => l_new_ben_pln_id,
                    p_ref_entity_type => i.ref_entity_type,
                    p_lead_source     => 'RENEWAL',
                    p_entity_type     => i.entity_type
                );
            end if;
        end loop;
        -- Added by Swamy for Ticket#10431 (Erisa Renewal)
        for u in (
            select
                user_type
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            if u.user_type = 'B' then
                l_renewed_by := 'BROKER';
                l_renewed_by_id := pc_account.get_broker_id(v_acc_id); -- Added by jaggi for Ticket#11533
            elsif u.user_type = 'G' then
                l_renewed_by := 'GA';
                l_renewed_by_id := pc_account.get_ga_id(v_acc_id);     -- Added by jaggi for Ticket#11533
            else
                l_renewed_by := 'EMPLOYER';
                l_renewed_by_id := v_acc_id;   -- Added by jaggi for Ticket#11533
            end if;
        end loop;

        update account
        set
            last_update_date = sysdate 
--               renewed_date     = CASE WHEN renewed_date IS NULL THEN SYSDATE ELSE  renewed_date  END-- 10431 Joshi
           --   ,renewed_by           = l_renewed_by     -- commented by swamy for Ticket# 11930  -- 10431 Joshi
            ,
            renewed_date = decode(v_resubmit_flag, 'N', sysdate, renewed_date)   -- Added by jaggi for ticket#11533
           --   ,renewed_by_id        = l_renewed_by_id  -- commented by swamy for Ticket# 11930                                  -- Added by jaggi for Ticket#11533
            ,
            submit_by = p_user_id    -- Added by Swamy for Ticket#11930
            ,
            signature_account_status = null                                           -- Added by jaggi for Ticket#11533
        where
            entrp_id = p_entrp_id;

        if nvl(v_resubmit_flag, 'N') = 'Y' then   -- Added by Swamy for Ticket#11533
            update account
            set
                renewed_by = l_renewed_by,
                renewed_by_id = l_renewed_by_id
            where
                entrp_id = p_entrp_id;

        end if;

        update online_compliance_staging
        set
            submit_status = 'COMPLETED'
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

/*
        -- Added by Jaggi for Ticket #11086
        IF l_renewed_by = 'EMPLOYER' THEN;*/  -- added by jaggi for ticket#11533

        if nvl(v_resubmit_flag, 'N') = 'N' then   -- Added by Swamy for Ticket#11533
            pc_employer_enroll_compliance.update_acct_pref(p_batch_number, p_entrp_id);
            select
                broker_id
            into l_broker_id
            from
                table ( pc_broker.get_broker_info_from_acc_id(v_acc_id) );

            if l_broker_id > 0 then
                l_authorize_req_id := pc_broker.get_broker_authorize_req_id(l_broker_id, v_acc_id);
                pc_broker.create_broker_authorize(
                    p_broker_id        => l_broker_id,
                    p_acc_id           => v_acc_id,
                    p_broker_user_id   => null,
                    p_authorize_req_id => l_authorize_req_id,
                    p_user_id          => p_user_id,
                    x_error_status     => x_error_status,
                    x_error_message    => x_error_message
                );

            end if;

        end if;
        -- code ends here by Joshi.

        pc_log.log_error('END Erisa_Renewal_final_submit calling Update_Contact_Info ', 'l_NEW_BEN_PLN_ID := ' || l_new_ben_pln_id);
    exception
        when erreur then
            rollback;
            x_error_status := 'E';
            x_error_message := v_phase || x_error_message;
            pc_log.log_error('PC_WEB_ER_RENEWAL.Erisa_Renewal_final_submit', 'Error '
                                                                             || x_error_message
                                                                             || ' := '
                                                                             || sqlerrm);
        when others then
            rollback;
            x_error_status := 'E';
            x_error_message := ' PC_WEB_ER_RENEWAL.Erisa_Renewal_final_submit ' || sqlerrm(sqlcode);
            pc_log.log_error('PC_WEB_ER_RENEWAL.Erisa_Renewal_final_submit',
                             'Phase '
                             || v_phase
                             || 'Others'
                             || dbms_utility.format_error_backtrace
                             || sqlerrm(sqlcode));

    end erisa_renewal_final_submit;

-- Added by swamy for Ticket#8684 on 19/05/2020
-- This procedure will be executed only once for the very fresh renewal just after generating the Batch_Number,
    procedure upsert_compliance_plan_staging (
        p_entrp_id            in number,
        p_plan_number         in varchar2,
        p_plan_type           in varchar2,
        p_plan_start_date     in varchar2,
        p_plan_end_date       in varchar2,
        p_user_id             in number,
        p_page_validity       in varchar2,
        p_batch_number        in number,
        p_plan_id             in number,
        p_ben_plan_id         in number,
        p_ben_plan_name       in varchar2,    -- Added by Jaggi #9905
        p_renewed_ben_plan_id in number,   -- Added by Swamy for Ticket#10431(Renewal Resubmit)
        x_error_status        out varchar2,
        x_error_message       out varchar2
    ) is

        l_count                 number;
        v_plan_start_date       varchar2(100);
        v_plan_end_date         varchar2(100);
        v_acc_id                account.acc_id%type;
        v_erissa_erap_doc_type  ben_plan_enrollment_setup.erissa_erap_doc_type%type;    -- Added by Swamy for Ticket#9665
        v_plan_name             ben_plan_enrollment_setup.ben_plan_name%type;   -- Added by Jaggi #9905
        v_renewal_resubmit_flag varchar2(10);
    begin
        for i in (
            select
                renewal_resubmit_flag
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            v_renewal_resubmit_flag := i.renewal_resubmit_flag;
        end loop;

        pc_log.log_error('PC_web_er_renewal.upsert_Compliance_Plan_Staging', 'P_Plan_Id'
                                                                             || p_plan_id
                                                                             || 'P_Entrp_Id :='
                                                                             || p_entrp_id
                                                                             || ' P_Batch_Number :='
                                                                             || p_batch_number
                                                                             || 'p_plan_end_date :='
                                                                             || p_plan_end_date
                                                                             || 'P_Plan_Start_Date :='
                                                                             || p_plan_start_date
                                                                             || 'v_renewal_resubmit_flag :='
                                                                             || v_renewal_resubmit_flag);

        if p_plan_id is null then
      /* Insert */
            v_acc_id := pc_entrp.get_acc_id(p_entrp_id);
            for j in (
                select
                    to_char((a.plan_end_date + 1), 'MM/DD/YYYY') as plan_start_date,
                    decode(
                        nvl(a.erissa_erap_doc_type, 'R'),
                        'R',
                        to_char((add_months((a.plan_end_date + 1), 12) - 1),
                                'MM/DD/YYYY'),
                        to_char((add_months((a.plan_end_date + 1), 60) - 1),
                                'MM/DD/YYYY')
                    )                                            as plan_end_date,
                    a.erissa_erap_doc_type     -- Added by Swamy for Ticket#9665
                    ,
                    a.ben_plan_name     -- Added by Jaggi #9905
                from
                    ben_plan_enrollment_setup a
                where
                        acc_id = v_acc_id
                    and ben_plan_id = (
                        select
                            max(ben_plan_id)
                        from
                            ben_plan_enrollment_setup bp
                        where
                            a.acc_id = bp.acc_id
                    )
            ) loop
                v_plan_start_date := j.plan_start_date;
                v_plan_end_date := j.plan_end_date;
                v_erissa_erap_doc_type := j.erissa_erap_doc_type;    -- Added by Swamy for Ticket#9665
                v_plan_name := j.ben_plan_name;     -- Added by Jaggi #9905
            end loop;

            insert into compliance_plan_staging (
                plan_id,
                ben_plan_id,
                entity_id,
                plan_type,
                plan_number,
                plan_start_date,
                plan_end_date,
                batch_number,
                erissa_erap_doc_type      -- Added by Swamy for Ticket#9665
                ,
                plan_name                 -- Added by Jaggi #9905
                ,
                created_by,
                creation_date
            ) values ( compliance_plan_seq.nextval,
                       p_ben_plan_id,
                       p_entrp_id,
                       p_plan_type,
                       p_plan_number,
                       nvl(p_plan_start_date, v_plan_start_date),
                       nvl(p_plan_end_date, v_plan_end_date),
                       p_batch_number,
                       v_erissa_erap_doc_type       -- Added by Swamy for Ticket#9665
                       ,
                       v_plan_name                  -- Added by Jaggi #9905
                       ,
                       p_user_id,
                       sysdate );

            pc_log.log_error('PC_web_er_renewal.upsert_Compliance_Plan_Staging calling populate_erisa_renewal_stage', 'p_ben_plan_id' || p_ben_plan_id
            );
            -- Added by Swamy for Ticket#9304 on 21/07/2020
            pc_web_er_renewal.populate_erisa_renewal_stage(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_ben_plan_id   => p_ben_plan_id,
                p_user_id       => p_user_id,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

            delete from contact_leads
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and account_type = 'ERISA_WRAP';

            pc_web_er_renewal.upsert_contact_leads(
                p_entrp_id      => p_entrp_id,
                p_user_id       => p_user_id,
                p_ben_plan_id   => p_ben_plan_id,
                p_account_type  => 'ERISA_WRAP',
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

        else
      /* Update */
            pc_log.log_error('PC_web_er_renewal.upsert_Compliance_Plan_Staging..Update', p_plan_start_date);
            update compliance_plan_staging
            set
                plan_number = p_plan_number,
                ben_plan_id = p_ben_plan_id,
                plan_type = p_plan_type,
                plan_name = p_ben_plan_name,        -- Added by Jaggi #9905
                plan_start_date = p_plan_start_date,
                plan_end_date = p_plan_end_date,
                last_updated_by = p_user_id,
                last_update_date = sysdate,
                renewed_ben_plan_id = p_renewed_ben_plan_id   -- Added by Swamy for Ticket#10431(Renewal Resubmit)
            where
                    batch_number = p_batch_number
                and entity_id = p_entrp_id
                and plan_id = p_plan_id;

            pc_log.log_error('PC_web_er_renewal.upsert_Compliance_Plan_Staging..After Update', p_plan_start_date);
        end if;

        x_error_status := 'S';
    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_web_er_renewal.upsert_Compliance_Plan_Staging', sqlerrm);
    end upsert_compliance_plan_staging;

-- Added by Jaggi for Ticket#8684 on 14/05/2020
    function get_payment_details (
        p_batch_number in number,
        p_entrp_id     in number
    ) return payment_t
        pipelined
        deterministic
    is
        l_record payment_row_t;
    begin
        for x in (
            select
                bank_name,
                routing_number,
                bank_acc_num,
                bank_acc_type,
                remittance_flag,
                fees_payment_flag,
                salesrep_id,
                salesrep_flag,
                send_invoice,
                (
                    select distinct
                        total_quote_price
                    from
                        ar_quote_headers_staging
                    where
                            entrp_id = a.entrp_id
                        and batch_number = p_batch_number
                ) total_cost,
                acct_payment_fees,
                bank_authorize              -- Added by Jaggi ##9602
            from
                online_compliance_staging a
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
        ) loop
            l_record.bank_name := x.bank_name;
            l_record.routing_number := x.routing_number;
            l_record.bank_acc_num := x.bank_acc_num;
            l_record.bank_acc_type := x.bank_acc_type;
            l_record.remittance_flag := x.remittance_flag;
            l_record.fees_payment_flag := x.fees_payment_flag;
            l_record.salesrep_id := x.salesrep_id;
            l_record.salesrep_flag := x.salesrep_flag;
            l_record.send_invoice := x.send_invoice;
            l_record.total_cost := x.total_cost;
            l_record.acct_payment_fees := x.acct_payment_fees;
            l_record.bank_authorize := x.bank_authorize;
            for i in (
                select
                    validity
                from
                    page_validity
                where
                        account_type = 'ERISA_WRAP'
                    and block_name = 'FEE_PAYMENT'
                    and page_no = '1'
                    and batch_number = p_batch_number
                    and entrp_id = p_entrp_id
            ) loop
                l_record.page_validity := i.validity;
            end loop;

            pipe row ( l_record );
        end loop;
    exception
        when others then
            pc_log.log_error('PC_web_er_renewal.Get_payment_details', sqlerrm);
    end get_payment_details;

-- Added by Jaggi for Ticket#8684 on 14/05/2020
    function get_employer_info (
        p_batch_number in number,
        p_entrp_id     in number
    ) return employer_info_t
        pipelined
        deterministic
    is
        l_employer_info employer_info_row_t;
    begin
        for x in (
            select
                state_of_org,
                fiscal_yr_end,
                type_of_entity,
                entity_name_desc,
                affliated_flag,
                cntrl_grp_flag,
                plan_id,
                plan_type,
                takeover_flag,
                plan_number,
                plan_start_date,
                plan_end_date,
                short_plan_yr_flag,
                flg_plan_name,
                flg_pre_adop_pln,
                plan_name,
                a.org_eff_date      as org_eff_date,
                a.effective_date    as effective_date,
                a.eff_date_sterling as eff_date_sterling,
                a.no_of_eligible,
                a.no_off_ees,
                b.erissa_erap_doc_type,
                (
                    select distinct
                        c.total_quote_price
                    from
                        ar_quote_headers_staging c
                    where
                            c.entrp_id = a.entrp_id
                        and c.batch_number = a.batch_number
                )                   total_cost
            from
                online_compliance_staging a,
                compliance_plan_staging   b
            where
                    a.batch_number = b.batch_number
                and a.batch_number = p_batch_number
                and a.entrp_id = p_entrp_id
        ) loop
            l_employer_info.state_of_org := x.state_of_org;
            l_employer_info.fiscal_yr_end := x.fiscal_yr_end;
            l_employer_info.type_of_entity := x.type_of_entity;
            l_employer_info.entity_name_desc := x.entity_name_desc;
            l_employer_info.affliated_flag := x.affliated_flag;
            l_employer_info.cntrl_grp_flag := x.cntrl_grp_flag;
            l_employer_info.plan_id := x.plan_id;
            l_employer_info.plan_type := x.plan_type;
            l_employer_info.takeover_flag := x.takeover_flag;
            l_employer_info.plan_number := x.plan_number;
            l_employer_info.plan_start_date := x.plan_start_date;
            l_employer_info.plan_end_date := x.plan_end_date;
            l_employer_info.short_plan_yr_flag := x.short_plan_yr_flag;
            l_employer_info.flg_plan_name := x.flg_plan_name;
            l_employer_info.flg_pre_adop_pln := x.flg_pre_adop_pln;
            l_employer_info.plan_name := x.plan_name;
            l_employer_info.org_eff_date := x.org_eff_date;
            l_employer_info.effective_date := x.effective_date;
            l_employer_info.eff_date_sterling := x.eff_date_sterling;
            l_employer_info.no_of_eligible := x.no_of_eligible;
            l_employer_info.no_off_ees := x.no_off_ees;
            l_employer_info.erissa_erap_doc_type := x.erissa_erap_doc_type;
            l_employer_info.total_cost := x.total_cost;
            pipe row ( l_employer_info );
        end loop;
    exception
        when others then
            pc_log.log_error('PC_web_er_renewal.Get_Employer_Info', sqlerrm);
    end get_employer_info;

-- Added by Jaggi for Ticket#8684 on 14/05/2020
    function get_contact_leads (
        p_entrp_id     in number,
        p_account_type varchar2,
        p_contact_type varchar2
    ) return contact_leads_t
        pipelined
        deterministic
    is
        l_contact_leads contact_leads_row_t;
    begin
        for x in (
--              SELECT First_Name
--                    ,Job_title
--                    ,PHONE_NUM
--                    ,CONTACT_FAX
--                    ,Email
--                    ,Contact_type
--                    ,Contact_id
--                    ,LIC_NUMBER
--                    ,contact_flg
--                    ,lic_number_flag
--                    ,prefetched_flg
--                    ,Validity
--                    ,ref_entity_type  -- added by Jaggi #11604
--                FROM Contact_leads
--               WHERE Entity_id    = PC_ENTRP.get_tax_id(p_entrp_id)
--                 AND Account_type = p_account_type
--                 AND Contact_type = NVL(p_contact_type,Contact_type)
                -- added by Jaggi #11687
            select
                cl.first_name      first_name,
                cl.job_title       job_title,
                cl.phone_num       phone_num,
                cl.contact_fax     contact_fax,
                cl.email           email,
                cl.contact_type    contact_type,
                cl.contact_id      contact_id,
                cl.lic_number      lic_number,
                cl.contact_flg     contact_flg,
                cl.lic_number_flag lic_number_flag,
                cl.prefetched_flg  prefetched_flg,
                cl.validity        validity,
                cl.ref_entity_type ref_entity_type
            from
                contact_leads cl,
                contact       c
            where
                    cl.contact_id = c.contact_id (+)
                and cl.entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and cl.account_type = p_account_type
                and cl.contact_type = nvl(p_contact_type, cl.contact_type)
                and nvl(c.status, 'A') = 'A'
        ) loop
            l_contact_leads.first_name := x.first_name;
            l_contact_leads.job_title := x.job_title;
            l_contact_leads.phone_num := x.phone_num;
            l_contact_leads.contact_fax := x.contact_fax;
            l_contact_leads.email := x.email;
            l_contact_leads.contact_type := x.contact_type;
            l_contact_leads.contact_id := x.contact_id;
            l_contact_leads.lic_number := x.lic_number;
            l_contact_leads.contact_flg := x.contact_flg;
            l_contact_leads.lic_number_flag := x.lic_number_flag;
            l_contact_leads.prefetched_flg := x.prefetched_flg;
            l_contact_leads.validity := x.validity;
            l_contact_leads.ref_entity_type := x.ref_entity_type;
            l_contact_leads.lic_number_flag := x.lic_number_flag;
            pipe row ( l_contact_leads );
        end loop;
    exception
        when others then
            pc_log.log_error('PC_web_er_renewal.Get_Contact_Leads', sqlerrm);
    end get_contact_leads;

-- Added by Swamy for Ticket#8684 on 19/05/2020
    procedure upsert_entrp_demographics (
        p_batch_number  in varchar2,
        p_entrp_id      in number,
        p_state_of_org  in varchar2,
        p_zip           in varchar2,
        p_city          in varchar2,
        p_address       in varchar2,
        p_user_id       in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
    begin
        update online_compliance_staging
        set
            state_of_org = p_state_of_org,
            zip = p_zip,
            city = p_city,
            address = p_address,
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        x_error_status := 'S';
    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm(sqlcode);
            pc_log.log_error('PC_web_er_renewal.Upsert_entrp_demographics', sqlerrm);
    end upsert_entrp_demographics;

    procedure upsert_contact_leads (
        p_entrp_id      in number,
        p_user_id       in varchar2,
        p_ben_plan_id   in number,
        p_account_type  in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_broker_id       broker.broker_id%type;
        l_ref_entity_type varchar2(100);
        l_ga_exits_flag   varchar2(1) := 'N';
    begin
        pc_log.log_error('PC_web_er_renewal.upsert_contact_leads', 'begin');
        for j in (
            select
                acc_num,
                account_type,
                acc_num
                || '('
                || account_type
                || ')' meaning,
                acc_id,
                entrp_id,
                broker_id
            from
                table ( pc_users.get_products(p_user_id) )
            where
                account_type = p_account_type
        ) loop
            l_broker_id := j.broker_id;
        end loop;

        for i in (
            select
                decode(plan_type, 'NEW', 'ONLINE_ENROLLMENT', 'RENEW', 'BEN_PLAN_RENEWALS') ref_entity_type
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id = p_ben_plan_id
        ) loop
            l_ref_entity_type := i.ref_entity_type;
        end loop;

        pc_log.log_error('PC_web_er_renewal.upsert_contact_leads', 'l_broker_id ' || l_broker_id);
        if l_broker_id <> 0 then
            for k in (
                select
                    broker_id,
                    broker_lic,
                    last_name,
                    first_name,
                    broker_name,
                    address,
                    city,
                    state,
                    zip,
                    broker_phone,
                    broker_email,
                    broker_email email,
                    broker_rate,
                    broker_comm  comm,
                    start_date,
                    agency_name
                from
                    table ( pc_broker.get_broker_info(l_broker_id) )
            ) loop
                insert into contact_leads (
                    contact_id,
                    first_name,
                    entity_id,
                    entity_type,
                    ref_entity_type,
                    email,
                    contact_type,
                    user_id,
                    phone_num,
                    contact_fax,
                    account_type,
                    lic_number,
                    ref_entity_id,
                    lic_number_flag,
                    contact_flg,
                    prefetched_flg,
                    creation_date
                ) values ( contact_seq.nextval,
                           k.first_name
                           || ' '
                           || k.last_name,
                           pc_entrp.get_tax_id(p_entrp_id),
                           'ENTERPRISE',
                           l_ref_entity_type,
                           k.broker_email,
                           'BROKER',
                           p_user_id,
                           k.broker_phone,
                           null,
                           p_account_type,
                           k.broker_lic,
                           p_ben_plan_id,
                           'Y',
                           'Y',
                           'Y',
                           sysdate );

            end loop;
        end if;

        for m in (
            select
                ga_id,
                agency_name,
                ga_lic,
                email
            from
                table ( pc_broker.get_ga_info(p_entrp_id) )
        ) loop
            insert into contact_leads (
                contact_id,
                first_name,
                entity_id,
                entity_type,
                ref_entity_type,
                email,
                contact_type,
                user_id,
                account_type,
                lic_number,
                ref_entity_id,
                lic_number_flag,
                contact_flg,
                prefetched_flg,
                creation_date
            ) values ( contact_seq.nextval,
                       m.agency_name,
                       pc_entrp.get_tax_id(p_entrp_id),
                       'ENTERPRISE',
                       l_ref_entity_type,
                       m.email,
                       'GA',
                       p_user_id,
                       p_account_type,
                       m.ga_lic,
                       p_ben_plan_id,
                       'Y',
                       'Y',
                       'Y',
                       sysdate );

            l_ga_exits_flag := 'Y';
        end loop;

        pc_log.log_error('PC_web_er_renewal.upsert_contact_leads', '**4 '
                                                                   || p_entrp_id
                                                                   || ' ** '
                                                                   || p_account_type);
        for n in (
            select
                a.contact_id,
                a.first_name,
                a.last_name,
                a.entity_id,
                a.entity_type,
                a.email,
                c.role_type contact_type,
                a.phone,
                a.fax,
                a.account_type
            from
                contact      a,
                contact_role c
            where
                    a.entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and nvl(a.status, 'A') = 'A'
                and c.role_type in ( 'BROKER', 'GA', 'PRIMARY' )
                and a.contact_id = c.contact_id
                and c.effective_end_date is null
                and a.email is not null
                and a.can_contact = 'Y'
                and a.account_type = p_account_type
                and not exists (
                    select
                        1
                    from
                        contact_leads cl
                    where
                        cl.contact_id = a.contact_id
                )
        ) loop
            pc_log.log_error('PC_web_er_renewal.upsert_contact_leads', 'l_broker_id '
                                                                       || l_broker_id
                                                                       || 'N.Contact_Type :='
                                                                       || n.contact_type);

            if
                n.contact_type = 'BROKER'
                and nvl(l_broker_id, 0) = 0
            then
                continue;
            end if;

            if
                n.contact_type = 'GA'
                and l_ga_exits_flag = 'N'
            then
                continue;
            end if;
            insert into contact_leads (
                contact_id,
                first_name,
                entity_id,
                entity_type,
                ref_entity_type,
                email,
                contact_type,
                user_id,
                phone_num,
                contact_fax,
                account_type,
                lic_number,
                ref_entity_id,
                lic_number_flag,
                contact_flg,
                prefetched_flg,
                creation_date
            ) values ( n.contact_id,
                       n.first_name
                       || ' '
                       || n.last_name,
                       n.entity_id,
                       'ENTERPRISE',
                       l_ref_entity_type,
                       n.email,
                       n.contact_type,
                       p_user_id,
                       n.phone,
                       n.fax,
                       n.account_type,
                       null,
                       p_ben_plan_id,
                       null,
                       'Y',
                       'Y',
                       sysdate );

        end loop;

    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm(sqlcode);
            pc_log.log_error('PC_web_er_renewal.upsert_contact_leads', sqlerrm);
    end upsert_contact_leads;

-- Added by Swamy for Ticket#9304 on 21/07/2020
    procedure populate_erisa_renewal_stage (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_ben_plan_id   in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_cnt                      number;
        l_batch_number             number;
        l_plan_type                varchar2(100);
        l_cnt_contact              number;
        l_cnt_ga                   number;
        l_ga_lic                   varchar2(100);
        l_affl_flag                varchar2(2) := 'N';
        l_cntrl_grp                varchar2(2) := 'N';
        v_flg_no_notice            varchar2(2);
        v_flg_addition             varchar2(2);
        v_no_of_eligible           enterprise.no_of_eligible%type;
        v_no_of_ees                enterprise.no_of_ees%type;
        v_plan                     ben_plan_enrollment_setup%rowtype;
        v_bank_details             user_bank_acct%rowtype;
        v_acc_id                   account.acc_id%type;
        v_ar_quote_headers         ar_quote_headers%rowtype;
        v_ben_plan_renewal         ben_plan_renewals%rowtype;
        v_notes                    notes%rowtype;
        v_flg_block                varchar2(2);
        v_benefit_code_name        varchar2(100);
        v_eligibility              benefit_codes_stage.eligibility%type;
        v_er_cont_pref             benefit_codes_stage.er_cont_pref%type;
        v_ee_cont_pref             benefit_codes_stage.ee_cont_pref%type;
        v_er_ee_contrib_lng        benefit_codes_stage.er_ee_contrib_lng%type;
        v_special_inst             notes.description%type;
        v_rate_plan_name           varchar2(100);
        v_coverage_type            varchar2(100);
        v_quote_header_id          number;
        v_fees_payment_flag        varchar2(10);
        v_contact_type             varchar2(10);
        v_intl_msrmnt_start_date   varchar2(20);
        v_msrmnt_start_date        varchar2(20);
        v_msrmnt_end_date          varchar2(20);
        v_admn_start_date          varchar2(20);
        v_admn_end_date            varchar2(20);
        v_stblt_start_date         varchar2(20);
        v_stblt_end_date           varchar2(20);
        v_same_prd_bnft_start_date varchar2(20);
        v_new_prd_bnft_start_date  varchar2(20);
        v_acct_payment_fees        ben_plan_renewals.pay_acct_fees%type;
        v_prev_batch               number;
        v_entity_name_desc         enterprise.entity_name_desc%type;
        l_broker_id                number;
        l_entity_type              varchar2(10);
        l_staging_bank_acct_id     number;
        l_return_status            varchar2(10);
        l_error_message            varchar2(500);
    begin
        pc_log.log_error('In populate_erisa_renewal_stage', p_batch_number
                                                            || ' p_entrp_id :='
                                                            || p_entrp_id
                                                            || ' p_ben_plan_id :='
                                                            || p_ben_plan_id
                                                            || ' p_user_id :='
                                                            || p_user_id);

  -- Added by swamy for ticket#10747
        pc_broker.get_broker_id(p_user_id, l_entity_type, l_broker_id);

  -- Get the Previous Batch Number if available.
        for q in (
            select
                max(batch_number) batch_number
            from
                online_compliance_staging a,
                account                   b
            where
                    a.entrp_id = b.entrp_id
                and a.entrp_id = p_entrp_id
                and b.account_type = 'ERISA_WRAP'
                and batch_number <> p_batch_number
        ) loop
            v_prev_batch := q.batch_number;
        end loop;

        for p in (
            select
                entity_name_desc
            from
                enterprise
            where
                entrp_id = p_entrp_id
        ) loop
            v_entity_name_desc := p.entity_name_desc;
        end loop;

      /* Created Affliated Employer and Controlled Group data */
        for xx in (
            select
                b.name,
                a.entity_id
            from
                entrp_relationships a,
                enterprise          b
            where
                    a.entrp_id = p_entrp_id
                and relationship_type = 'AFFILIATED_ER'
                and a.entity_id = b.entrp_id
                and b.en_code = 10
        ) loop
            pc_log.log_error('In Populate renewal..PLAN ID', 'Aff1');
            l_affl_flag := 'Y';
          /*Creating Affliated Employer */
            insert into enterprise_staging (
                entrp_stg_id,
                entrp_id,
                en_code,
                name,
                batch_number,
                entity_type,
                created_by,
                creation_date
            ) values ( entrp_staging_seq.nextval,
                       p_entrp_id,
                       10,
                       xx.name,
                       p_batch_number,
                       'BEN_PLAN_RENEWALS',
                       p_user_id,
                       sysdate );

        end loop;

         /* Created Affliated Employer and Controlled Group data */
        for xx in (
            select
                b.name,
                a.entity_id
            from
                entrp_relationships a,
                enterprise          b
            where
                    a.entrp_id = p_entrp_id
                and relationship_type = 'CONTROLLED_GROUP'
                and a.entity_id = b.entrp_id
                and b.en_code = 11
        ) loop
           /*Creating Controlled group Employer */
            l_cntrl_grp := 'Y';
            insert into enterprise_staging (
                entrp_stg_id,
                entrp_id,
                en_code,
                name,
                batch_number,
                entity_type,
                created_by,
                creation_date
            ) values ( entrp_staging_seq.nextval,
                       p_entrp_id,
                       11,
                       xx.name,
                       p_batch_number,
                       'BEN_PLAN_RENEWALS',
                       p_user_id,
                       sysdate );

        end loop;

        pc_log.log_error('In populate_erisa_renewal_stage', 'l_affl_flag :='
                                                            || l_affl_flag
                                                            || 'l_cntrl_grp :='
                                                            || l_cntrl_grp);
        for n in (
            select
                census_numbers
            from
                enterprise_census
            where
                    entity_id = p_entrp_id
                and census_code = 'NO_OF_EMPLOYEES'
                and entity_type = 'ENTERPRISE'
                and nvl(ben_plan_id, 1) in ( p_ben_plan_id, 1 )
            order by
                nvl(ben_plan_id, 1) desc
        ) loop
            v_no_of_ees := n.census_numbers;
            exit;
        end loop;

        v_acc_id := pc_entrp.get_acc_id(p_entrp_id);
        if nvl(l_entity_type, '*') <> 'BROKER' then   -- Added only If cond by Swamy for Ticket#10986 (10747 Dev ticket)
            for j in (
                select
                    *
                from
                    user_bank_acct
                where
                        status = 'A'
                    and acc_id = v_acc_id
            ) loop
                v_bank_details := j;
            end loop;
        end if;

        pc_log.log_error('In populate_erisa_renewal_stage', p_ben_plan_id);
        for i in (
            select
                *
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id = p_ben_plan_id
        ) loop
            v_plan := i;
        end loop;

        for k in (
            select
                plan_id,
                plan_type
            from
                compliance_plan_staging
            where
                    entity_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            l_plan_type := k.plan_type;
        end loop;

        for n in (
            select
                *
            from
                ar_quote_headers
            where
                    entrp_id = p_entrp_id
                and ben_plan_id = p_ben_plan_id
        ) loop
            v_ar_quote_headers := n;
        end loop;

        for m in (
            select
                *
            from
                ben_plan_renewals
            where
                    acc_id = v_acc_id
                and renewed_plan_id = p_ben_plan_id
        ) loop
            v_ben_plan_renewal := m;
        end loop;

        if nvl(l_entity_type, '*') <> 'BROKER' then   -- Added only If cond by Swamy for Ticket#10986 (10747 Dev ticket)
            v_acct_payment_fees := v_ben_plan_renewal.pay_acct_fees;
            if nvl(v_acct_payment_fees, '*') = '*' then
                v_acct_payment_fees := v_ar_quote_headers.pay_acct_fees;
            end if;

            if
                nvl(v_acct_payment_fees, '*') = '*'
                and v_prev_batch is not null
            then
                for z in (
                    select
                        acct_payment_fees
                    from
                        online_compliance_staging
                    where
                        batch_number = v_prev_batch
                ) loop
                    v_acct_payment_fees := z.acct_payment_fees;
                end loop;
            end if;

	  -- Added by Swamy for Ticket#12698
            pc_giact_validations.populate_giact_renewal_staging(
                p_batch_number         => p_batch_number,
                p_entrp_id             => p_entrp_id,
                p_user_id              => p_user_id,
                p_account_type         => 'ERISA_WRAP',
                p_ben_plan_id          => v_plan.ben_plan_id,
                x_staging_bank_acct_id => l_staging_bank_acct_id,
                x_return_status        => l_return_status,
                x_error_message        => l_error_message
            );

        end if;

        for p in (
            select
                *
            from
                notes
            where
                    entity_id = p_ben_plan_id
                and acc_id = v_acc_id
                and entrp_id = p_entrp_id
        ) loop
            v_notes := p;
        end loop;

        if lower(v_ar_quote_headers.payment_method) = 'check' then
            v_fees_payment_flag := 'check';
        elsif lower(v_ar_quote_headers.payment_method) = 'ach' then
            v_fees_payment_flag := 'ACH';
        elsif lower(v_ar_quote_headers.payment_method) = 'ach_push' then   -- Added by Swamy for Ticket#12698
            v_fees_payment_flag := 'ACH_PUSH';
        end if;

        pc_log.log_error('In populate_erisa_renewal_stage', 'v_NO_OF_ELIGIBLE :='
                                                            || v_no_of_eligible
                                                            || 'p_entrp_id :='
                                                            || p_entrp_id
                                                            || 'p_batch_number :='
                                                            || p_batch_number
                                                            || 'v_FEES_PAYMENT_FLAG :='
                                                            || v_fees_payment_flag);

        update online_compliance_staging
        set
            effective_date = to_char(v_plan.effective_date, 'mm/dd/yyyy'),
            org_eff_date = to_char(v_plan.original_eff_date, 'mm/dd/yyyy'),
            affliated_flag = l_affl_flag,
            cntrl_grp_flag = l_cntrl_grp,
            fiscal_yr_end = null   --TO_CHAR(v_plan.fiscal_end_date,'mm/dd/yyyy') -- Added by Jaggi #10743 fiscal yr end should freeze
           -- ,NO_OF_ELIGIBLE  = v_NO_OF_ELIGIBLE
            ,
            no_off_ees = v_no_of_ees 
           -- ,BANK_NAME         = v_bank_details.BANK_NAME                -- commented by Swamy for Ticket#12698
           -- ,ROUTING_NUMBER    =  v_bank_details.bank_ROUTING_NUM        -- commented by Swamy for Ticket#12698
           -- ,BANK_ACC_NUM      =  v_bank_details.BANK_ACCt_NUM           -- commented by Swamy for Ticket#12698
           -- ,BANK_ACC_TYPE     =  v_bank_details.BANK_ACCt_TYPE          -- commented by Swamy for Ticket#12698
            ,
            fees_payment_flag = v_fees_payment_flag,
            acct_payment_fees = initcap(v_acct_payment_fees),
            entity_name_desc = v_entity_name_desc
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        pc_log.log_error('In populate_erisa_renewal_stage', 'v_plan.erissa_erap_doc_type :='
                                                            || v_plan.erissa_erap_doc_type
                                                            || 'v_NO_OF_EES :='
                                                            || v_no_of_ees
                                                            || 'v_plan.Wrap_Plan_5500 :='
                                                            || v_plan.wrap_plan_5500);

        update compliance_plan_staging
        set
            grandfathered = v_plan.grandfathered,
            self_administered = v_plan.self_administered,
            clm_lang_in_spd = v_plan.clm_lang_in_spd,
            subsidy_in_spd_apndx = v_plan.subsidy_in_spd_apndx,
            wrap_opt_flg = v_plan.wrap_opt_flg
          --  ,erissa_erap_doc_type = nvl(v_plan.erissa_erap_doc_type,'R')
        where
                entity_id = p_entrp_id
            and batch_number = p_batch_number;

        v_quote_header_id := quote_header_id_seq.nextval;
         --Pricing InFORmation **/
        insert into ar_quote_headers_staging (
            quote_header_id,
            entrp_id,
            payment_method,
            total_quote_price,
            ben_plan_id,
            batch_number,
            account_type,
            created_by,
            creation_date
        )
            (
                select
                    v_quote_header_id,
                    p_entrp_id,
                    v_ar_quote_headers.payment_method,
                    v_ar_quote_headers.total_quote_price,
                    p_ben_plan_id,
                    p_batch_number,
                    l_plan_type,
                    p_user_id,
                    sysdate
                from
                    ar_quote_headers
                where
                        entrp_id = p_entrp_id
                    and ben_plan_id = p_ben_plan_id
            );

        if v_plan.erissa_erap_doc_type = 'E' then
            v_rate_plan_name := 'ERISA_WRAP_EVERGREEN_FEES';
            v_coverage_type := 'RENEWAL_FEE';
        else
            v_rate_plan_name := 'ERISA_WRAP_STANDARD_FEES';
            v_coverage_type := 'ANNUAL_FEE';
        end if;

        for ar in (
            select
                a.rate_plan_id,
                b.rate_plan_detail_id,
                b.rate_plan_cost
            from
                rate_plans       a,
                rate_plan_detail b
            where
                    a.rate_plan_id = b.rate_plan_id
                and a.rate_plan_name = v_rate_plan_name
                and account_type = 'ERISA_WRAP'
                and coverage_type = v_coverage_type
                and minimum_range < v_no_of_eligible
                and maximum_range >= v_no_of_eligible
        ) loop
            if ar.rate_plan_detail_id is not null then
                insert into ar_quote_lines_staging (
                    quote_line_id,
                    quote_header_id,
                    rate_plan_id,
                    rate_plan_detail_id,
                    line_list_price,
                    batch_number,
                    created_by,
                    creation_date
                ) values ( compliance_quote_lines_seq.nextval,
                           v_quote_header_id,
                           ar.rate_plan_id,
                           ar.rate_plan_detail_id,
                           ar.rate_plan_cost,
                           p_batch_number,
                           p_user_id,
                           sysdate );

            end if;
        end loop;

        insert into erisa_aca_eligibility_stage (
            eligibility_id,
            entrp_id,
            ben_plan_id,
            batch_number,
            aca_ale_flag,
            variable_hour_flag,
            irs_lbm_flag,
            collective_bargain_flag,
            wrap_plan_5500,
            special_inst,
            created_by,
            creation_date
        ) values ( erisa_aca_seq.nextval,
                   p_entrp_id,
                   p_ben_plan_id,
                   p_batch_number,
                   'N',
                   'N',
                   'Y',
                   v_plan.is_collective_plan,
                   v_plan.wrap_plan_5500,
                   v_notes.description,
                   p_user_id,
                   sysdate );

        for e in (
            select
                erisa_aca_seq.nextval,
                ben_plan_id,
                aca_ale_flag,
                variable_hour_flag,
                intl_msrmnt_period,
                intl_msrmnt_start_date,
                intl_admn_period,
                stblty_period,
                msrmnt_start_date,
                msrmnt_period,
                msrmnt_end_date,
                admn_start_date,
                admn_period,
                admn_end_date,
                stblt_start_date,
                stblt_period,
                stblt_end_date,
                irs_lbm_flag,
                mnthl_msrmnt_flag,
                same_prd_bnft_start_date,
                new_prd_bnft_start_date,
                fte_hrs,
                fte_look_back,
                fte_salary_msmrt_period,
                fte_hourly_msmrt_period,
                fte_other_msmrt_period,
                fte_other_ee_detail,
                fte_lkp_other_ee_detail,
                fte_lkp_salary_msmrt_period,
                fte_lkp_hourly_msmrt_period,
                fte_lkp_other_msmrt_period,
                collective_bargain_flag,
                intl_msrmnt_period_det,
                fte_same_period_select,
                fte_diff_period_select,
                define_intl_msrmnt_period,
                fte_same_period_resume_date,
                fte_diff_period_resume_date
            from
                erisa_aca_eligibility
            where
                ben_plan_id = p_ben_plan_id
        ) loop
            v_intl_msrmnt_start_date := to_char(e.intl_msrmnt_start_date, 'mm/dd/yyyy');
            v_msrmnt_start_date := to_char(e.msrmnt_start_date, 'mm/dd/yyyy');
            v_msrmnt_end_date := to_char(e.msrmnt_end_date, 'mm/dd/yyyy');
            v_admn_start_date := to_char(e.admn_start_date, 'mm/dd/yyyy');
            v_admn_end_date := to_char(e.admn_end_date, 'mm/dd/yyyy');
            v_stblt_start_date := to_char(e.stblt_start_date, 'mm/dd/yyyy');
            v_stblt_end_date := to_char(e.stblt_end_date, 'mm/dd/yyyy');
            v_same_prd_bnft_start_date := to_char(e.same_prd_bnft_start_date, 'mm/dd/yyyy');
            v_new_prd_bnft_start_date := to_char(e.new_prd_bnft_start_date, 'mm/dd/yyyy');

            -- Eligibiity requirement Info
            update erisa_aca_eligibility_stage
            set
                aca_ale_flag = e.aca_ale_flag,
                variable_hour_flag = e.variable_hour_flag,
                intl_msrmnt_period = e.intl_msrmnt_period,
                intl_msrmnt_start_date = e.intl_msrmnt_start_date,
                intl_admn_period = e.intl_admn_period,
                stblty_period = e.stblty_period,
                msrmnt_start_date = v_msrmnt_start_date,
                msrmnt_period = e.msrmnt_period,
                msrmnt_end_date = v_msrmnt_end_date,
                admn_start_date = v_admn_start_date,
                admn_period = e.admn_period,
                admn_end_date = v_admn_end_date,
                stblt_start_date = v_stblt_start_date,
                stblt_period = e.stblt_period,
                stblt_end_date = v_stblt_end_date,
                irs_lbm_flag = e.irs_lbm_flag,
                mnthl_msrmnt_flag = e.mnthl_msrmnt_flag,
                same_prd_bnft_start_date = v_same_prd_bnft_start_date,
                new_prd_bnft_start_date = v_new_prd_bnft_start_date,
                fte_hrs = e.fte_hrs,
                fte_look_back = e.fte_look_back,
                fte_salary_msmrt_period = e.fte_salary_msmrt_period,
                fte_hourly_msmrt_period = e.fte_hourly_msmrt_period,
                fte_other_msmrt_period = e.fte_other_msmrt_period,
                fte_other_ee_detail = e.fte_other_ee_detail,
                fte_lkp_other_ee_detail = e.fte_lkp_other_ee_detail,
                fte_lkp_salary_msmrt_period = e.fte_lkp_salary_msmrt_period,
                fte_lkp_hourly_msmrt_period = e.fte_lkp_hourly_msmrt_period,
                fte_lkp_other_msmrt_period = e.fte_lkp_other_msmrt_period,
                collective_bargain_flag = v_plan.is_collective_plan,
                intl_msrmnt_period_det = e.intl_msrmnt_period_det,
                fte_same_period_select = e.fte_same_period_select,
                fte_diff_period_select = e.fte_diff_period_select,
                define_intl_msrmnt_period = e.define_intl_msrmnt_period,
                fte_same_period_resume_date = e.fte_same_period_resume_date,
                fte_diff_period_resume_date = e.fte_diff_period_resume_date,
                wrap_plan_5500 = v_plan.wrap_plan_5500,
                special_inst = v_notes.description
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id;

        end loop;

        -- Benefit Codes
        for b in (
            select
                benefit_code_name,
                description,
                entity_type,
                er_cont_pref,
                ee_cont_pref,
                eligibility_code,
                er_ee_contrib_lng_code,
                eligibility_refer_to_doc,
                fully_insured_flag,
                self_insured_flag,
                refer_to_doc,
                flg_block,
                voluntary_life_add_info
            from
                benefit_codes
            where
                    entity_id = p_ben_plan_id
                and ( ( upper(substr(benefit_code_name, 1, 5)) = 'OTHER' )
                      or ( benefit_code_name in ( 'CLAIM_LNG_OPT1', 'CLAIM_LNG_OPT10', 'CLAIM_LNG_OPT11', 'CLAIM_LNG_OPT12', 'CLAIM_LNG_OPT7'
                      ,
                                                  'CLAIM_LNG_OPT8', 'CLAIM_LNG_OPT9', 'CLAIM_LNG_OPT14', 'ACCIDENTAL', 'MEDICAL_PLAN'
                                                  ,
                                                  'DENTAL_HMO_PLAN', 'VOLUNTARY_LIFE_ADD', 'LTD', 'STD', 'LIFE_INSURANCE',
                                                  'HRA', 'VISION', 'CLAIM_LNG_OPT2', 'CLAIM_LNG_OPT3', 'CLAIM_LNG_OPT4',
                                                  'CLAIM_LNG_OPT11', 'CLAIM_LNG_OPT12', 'CLAIM_LNG_OPT1', 'CLAIM_LNG_OPT2', 'CLAIM_LNG_OPT3'
                                                  ,
                                                  'CLAIM_LNG_OPT4' ) ) )
        ) loop
            if upper(substr(b.benefit_code_name, 1, 5)) = 'OTHER' then
                v_benefit_code_name := 'OTHER';
            else
                v_benefit_code_name := b.benefit_code_name;
            end if;

            insert into benefit_codes_stage (
                benefit_code_id,
                entity_id,
                benefit_code_name,
                batch_number,
                description,
                entity_type,
                er_cont_pref,
                ee_cont_pref,
                eligibility,
                flg_block,
                er_ee_contrib_lng,
                entrp_id,
                eligibility_refer_to_doc,
                fully_insured_flag,
                self_insured_flag,
                refer_to_doc,
                voluntary_life_add_info,
                created_by,
                creation_date,
                last_updated_by
            ) values ( benefit_code_seq.nextval,
                       p_ben_plan_id,
                       v_benefit_code_name,
                       p_batch_number,
                       b.description
                    --,b.entity_type
                       ,
                       decode(b.flg_block, '2', 'SUBSIDIARY_CONTRACT', 'BEN_PLAN_RENEWAL'),
                       b.er_cont_pref,
                       b.ee_cont_pref,
                       b.eligibility_code,
                       b.flg_block,
                       b.er_ee_contrib_lng_code,
                       p_entrp_id,
                       b.eligibility_refer_to_doc,
                       b.fully_insured_flag,
                       b.self_insured_flag,
                       b.refer_to_doc,
                       b.voluntary_life_add_info,
                       p_user_id,
                       sysdate,
                       p_user_id );

        end loop;

        for p in (
            select
                plan_admin_name,
                contact_type,
                contact_name,
                phone_num,
                email,
                address1,
                address2,
                city,
                state,
                zip_code,
                plan_agent,
                description,
                agent_name,
                legal_agent_contact,
                legal_agent_phone,
                legal_agent_email,
                trust_fund,
                record_id,
                admin_type,
                trustee_name,
                trustee_contact_type,
                trustee_contact_name,
                trustee_contact_phone,
                trustee_contact_email,
                legal_agent_contact_type,
                governing_state
            from
                plan_employer_contacts
            where
                entity_id = p_ben_plan_id
        ) loop
            if nvl(p.contact_type, '*') = '*' then
                v_contact_type := 'Y';
                if nvl(p.contact_name, '*') <> '*' then
                    v_contact_type := 'N';
                end if;

            end if;

            insert into plan_employer_contacts_stage (
                plan_admin_name,
                contact_type,
                contact_name,
                phone_num,
                email,
                address1,
                address2,
                city,
                state,
                zip_code,
                plan_agent,
                description,
                agent_name,
                legal_agent_contact,
                legal_agent_phone,
                legal_agent_email,
                trust_fund,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                record_id,
                entity_id,
                batch_number,
                admin_type,
                trustee_name,
                trustee_contact_type,
                trustee_contact_name,
                trustee_contact_phone,
                trustee_contact_email,
                legal_agent_contact_type,
                governing_state
            ) values ( p.plan_admin_name,
                       p.contact_type,
                       p.contact_name,
                       p.phone_num,
                       p.email,
                       p.address1,
                       p.address2,
                       p.city,
                       p.state,
                       p.zip_code,
                       p.plan_agent,
                       p.description,
                       p.agent_name,
                       p.legal_agent_contact,
                       p.legal_agent_phone,
                       p.legal_agent_email,
                       p.trust_fund,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p.record_id,
                       p_entrp_id,
                       p_batch_number,
                       p.admin_type,
                       p.trustee_name,
                       p.trustee_contact_type,
                       p.trustee_contact_name,
                       p.trustee_contact_phone,
                       p.trustee_contact_email,
                       p.legal_agent_contact_type,
                       p.governing_state );

        end loop;

        insert into plan_notices_stage (
            plan_notice_id,
            entity_id,
            entrp_id,
            entity_type,
            notice_type,
            batch_number
        )
            (
                select
                    plan_notice_seq.nextval,
                    entity_id,
                    entrp_id,
                    'BEN_PLAN_RENEWALS',
                    notice_type,
                    p_batch_number
                from
                    plan_notices
                where
                        entrp_id = p_entrp_id
                    and entity_id = p_ben_plan_id
                    and notice_type not in ( 'NO_NOTICE' )
            );

        v_flg_no_notice := 'N';
        for g in (
            select
                notice_type
            from
                plan_notices_stage
            where
                notice_type in ( 'CHIPRA_ANN_NOTICE', 'COBRA_NOTICE', 'QMCSO_PROCEDURES' )
                and batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and entity_id = p_ben_plan_id
        ) loop
            v_flg_no_notice := null;
        end loop;

        for g in (
            select
                notice_type
            from
                plan_notices_stage
            where
                notice_type in ( 'ADVERSE_BEN', 'FINAL_ADVERSE_BEN' )
                and batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and entity_id = p_ben_plan_id
        ) loop
            v_flg_addition := 'Y';
        end loop;

        insert into plan_notices_stage (
            plan_notice_id,
            entity_id,
            entrp_id,
            entity_type,
            notice_type,
            batch_number,
            flg_no_notice,
            flg_addition
        ) values ( plan_notice_seq.nextval,
                   p_ben_plan_id,
                   p_entrp_id,
                   'BEN_PLAN_RENEWALS',
                   '5500',
                   p_batch_number,
                   v_flg_no_notice,
                   nvl(v_flg_addition, 'N') );

    exception
        when others then
            x_error_message := sqlerrm;
            pc_log.log_error('In populate_erisa_renewal_stage..', sqlerrm);
    end populate_erisa_renewal_stage;

-- Added by Swamy for Ticket#10751
-- Get only the plans which are active.
-- From php select lookup_code,description from TABLE(PC_EMPLOYER_ENROLL.get_fsa_plan_type) query is used to fetch all the plans and then minus the plans which are the result of the below procedure to get the plans to be added during renewal.
-- Plans to be added during renewal is the plans which are not enrolled, and plans which are declined and plans which are outdated (plan end date > 365 days)
-- The list is to provide the plan list during Renewal under "Renewal Add New Plan" section
    function get_renewal_plans (
        p_acc_id in varchar2
    ) return tbl_er_plan
        pipelined
    is

        l_display_flag varchar2(1);
        l_no_days      number;
        rec            rec_er_plan;
        l_plan_exists  varchar2(1);
        l_declined     varchar2(1);
    begin
        pc_log.log_error('pc_web_er_renewal.Get_Renewal_Plans', 'begin ');
        for i in (
            select distinct
                b.lookup_code,
                b.description
            from
                ben_plan_enrollment_setup a,
                lookups                   b
            where
                    acc_id = p_acc_id
                and b.lookup_name = 'FSA_PLAN_TYPE'
                and b.lookup_code = a.plan_type
                and b.lookup_code not in ( 'HRP', 'HR5', 'NDT', 'HR4', 'ACO',
                                           'IIR', 'HRA' )
        ) loop
--and not exists (select 1 from ben_plan_denials d where d.ben_plan_id = a.ben_plan_id and d.acc_id = a.acc_id)) loop
            pc_log.log_error('pc_web_er_renewal.Get_Renewal_Plans', 'i.lookup_code ' || i.lookup_code);
            l_display_flag := 'Y';
            l_no_days := 0;
            l_declined := 'N';
            l_plan_exists := 'N';

       -- Check if the plan is already displayed during renewals(under Active renewals plan section), if it is displayed then it should not display under (Renewal Add New Plan) section.
       -- So setting the flag l_display_flag as 'Y'
            for n in (
                select
                    c.declined,
                    c.ben_plan_id
                from
                    table ( pc_web_er_renewal.get_er_plans(p_acc_id) ) c
                where
                    c.plan_type = i.lookup_code
            ) loop
                if n.declined = 'N' then
                    l_plan_exists := 'Y';
                else
                    for j in (
                        select
                            trunc(max(creation_date)) creation_date
                        from
                            ben_plan_denials d
                        where
                                d.acc_id = p_acc_id
                            and d.ben_plan_id = n.ben_plan_id
                    ) loop
                        if j.creation_date < trunc(sysdate) then
                            l_declined := 'N';
                            l_display_flag := 'N';
                        else
                            l_declined := n.declined;
                            l_display_flag := 'Y';
                        end if;
                    end loop;
                end if;
            end loop;

            pc_log.log_error('pc_web_er_renewal.Get_Renewal_Plans', 'i.lookup_code '
                                                                    || i.lookup_code
                                                                    || ' l_declined :='
                                                                    || l_declined
                                                                    || 'l_plan_exists :='
                                                                    || l_plan_exists
                                                                    || 'l_display_flag :='
                                                                    || l_display_flag
                                                                    || 'l_no_days :='
                                                                    || l_no_days);

            if l_declined = 'N' then
                if i.lookup_code in ( 'TRN', 'PKG', 'UA1' ) then
           -- If plans are not displayed during renewals in the Active renewals plan section then
                    if l_plan_exists = 'N' then
                        for j in (
                            select
                                max(trunc(end_date)) plan_end_date
                            from
                                ben_plan_renewals r
                            where
                                    r.acc_id = p_acc_id
                                and plan_type = i.lookup_code
                        ) loop
                            l_no_days := trunc(sysdate) - j.plan_end_date;
                        end loop;

                        pc_log.log_error('pc_web_er_renewal.Get_Renewal_Plans', 'first l_no_days '
                                                                                || l_no_days
                                                                                || ' i.lookup_code :='
                                                                                || i.lookup_code);

                        if nvl(l_no_days, 0) = 0 then
                            for m in (
                                select
                                    max(trunc(plan_start_date)) plan_start_date
                                from
                                    ben_plan_enrollment_setup e
                                where
                                        e.acc_id = p_acc_id
                                    and e.plan_type = i.lookup_code
                                    and ( trunc(sysdate) - trunc(e.creation_date) ) > 185
                            ) loop
                                l_no_days := trunc(sysdate) - m.plan_start_date;
                            end loop;
                        end if;

                        pc_log.log_error('pc_web_er_renewal.Get_Renewal_Plans', 'second l_no_days ' || l_no_days);
                        if nvl(l_no_days, 0) >= 365 then
                            l_display_flag := 'N';
                        end if;

                    end if;

                else
           -- Get the latest plan id for a particular plan to check if it is inactive(meaning the plan is not renewed more than 365 days
                    for k in (
                        select
                            max(trunc(plan_end_date)) plan_end_date,
                            max(ben_plan_id)          ben_plan_id
                        from
                            ben_plan_enrollment_setup
                        where
                                acc_id = p_acc_id
                            and plan_type = i.lookup_code
                    ) loop
                        l_no_days := trunc(sysdate) - k.plan_end_date;
                        pc_log.log_error('pc_web_er_renewal.Get_Renewal_Plans', 'l_no_days '
                                                                                || l_no_days
                                                                                || ' k.plan_end_date :='
                                                                                || k.plan_end_date);

              -- If it more than 365 days setting the flay as N, inorder to display in the php screen
                        if l_no_days >= 365 then
                            l_display_flag := 'N';
                        else
                 -- Check to see if the plan is declined
                            for p in (
                                select
                                    d.ben_plan_id,
                                    trunc(d.creation_date) creation_date
                                from
                                    ben_plan_denials          d,
                                    ben_plan_enrollment_setup b
                                where
                                        d.ben_plan_id = b.ben_plan_id
                                    and b.plan_type = i.lookup_code
                                    and d.acc_id = b.acc_id
                                    and d.acc_id = p_acc_id
                            ) loop
                       -- IF the plan is declined
                                if nvl(p.ben_plan_id, 0) <> 0 then
                         -- Check if a new plan is created in place of the declined plan, using Add new plans during plan renewal.
                         -- If a new plan is already created then do not show in the Add new plans section
                                    if p.ben_plan_id < k.ben_plan_id then
                                        l_display_flag := 'Y';
                         -- if there is no new plan added previously and if it declined on the same day, if it is declined on nth day, then the plan should not reappear in the add new plans section during renewal of another plan on the same day.
                                    elsif
                                        p.ben_plan_id = k.ben_plan_id
                                        and p.creation_date < trunc(sysdate)
                                    then
                                        l_display_flag := 'N';
                                    end if;

                                end if;
                            end loop;
                        end if;

                        pc_log.log_error('pc_web_er_renewal.Get_Renewal_Plans', 'l_no_days '
                                                                                || l_no_days
                                                                                || ' l_display_flag :='
                                                                                || l_display_flag);
                    end loop;
                end if;
            end if;

            pc_log.log_error('pc_web_er_renewal.Get_Renewal_Plans', 'l_display_flag '
                                                                    || l_display_flag
                                                                    || ' i.lookup_code :='
                                                                    || i.lookup_code);
    -- Only if the l_display_flag = N, the plan will be displayed in the Add new plans section in php during renewal.
    -- If l_display_flag = Y then the plans will not be displayed in the add new plans section during renewal.
            if l_display_flag = 'Y' then
                rec.lookup_code := i.lookup_code;
                rec.description := i.description;
                pipe row ( rec );
            end if;

        end loop;

    end get_renewal_plans;

 -- added by jaggi #10743
    procedure update_fiscal_yr_enddate (
        p_entrp_id     in number,
        p_batch_number in number
    ) is
    begin
        update online_compliance_staging
        set
            fiscal_yr_end = null
        where
                entrp_id = p_entrp_id
            and source = 'RENEWAL'
            and batch_number = p_batch_number;

    end update_fiscal_yr_enddate;

-- Added by Swamy for Ticket#11636 on 28/06/2023
    function get_contact (
        p_entrp_id     in number,
        p_account_type varchar2,
        p_contact_type varchar2
    ) return contact_leads_t
        pipelined
        deterministic
    is
        l_contact_leads contact_leads_row_t;
    begin
        for x in (
            select
                first_name,
                title,
                phone,
                fax,
                email,
                contact_type,
                contact_id
            from
                contact
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and nvl(contact_type, '*') = nvl(p_contact_type,
                                                 nvl(contact_type, '*'))
                and status = 'A'
                and can_contact = 'Y'
                and upper(nvl(contact_type, '*')) in ( 'PRIMARY', 'GA', 'BROKER' )
        ) loop
            l_contact_leads.first_name := x.first_name;
            l_contact_leads.job_title := x.title;
            l_contact_leads.phone_num := x.phone;
            l_contact_leads.contact_fax := x.fax;
            l_contact_leads.email := x.email;
            l_contact_leads.contact_type := x.contact_type;
            l_contact_leads.contact_id := x.contact_id;
            pipe row ( l_contact_leads );
        end loop;
    exception
        when others then
            pc_log.log_error('PC_web_er_renewal.Get_Contact', sqlerrm);
    end get_contact;

   -- Added by Swamy for Ticket#11636 on 28/06/2023
    function get_acct_fee_details (
        p_entrp_id     in number,
        p_account_type varchar2,
        p_batch_number number
    ) return tbl_acct_fee_dtl
        pipelined
        deterministic
    is
        l_acct_fee rec_acct_fee_dtl;
    begin
        for x in (
            select
                a.acc_id,
                a.account_type,
                b.name,
                decode(o.acct_payment_fees, 'GA', 'General Agent', 'BROKER', 'Broker',
                       'EMPLOYER', 'Employer') acct_payment_fees
            from
                account                   a,
                enterprise                b,
                online_compliance_staging o
            where
                    a.entrp_id = p_entrp_id
                and a.entrp_id = b.entrp_id
                and a.entrp_id = o.entrp_id
                and o.batch_number = p_batch_number
        ) loop
            l_acct_fee.er_name := x.name;
            l_acct_fee.acct_payment_fees := x.acct_payment_fees;
            l_acct_fee.acc_id := x.acc_id;
            l_acct_fee.account_type := x.account_type;
            pipe row ( l_acct_fee );
        end loop;
    exception
        when others then
            pc_log.log_error('PC_web_er_renewal.Get_acct_fee_details', sqlerrm);
    end get_acct_fee_details;

-- Added by Joshi for ticket 12003 
    function get_plan_end_date_for_trn_pkg (
        p_acc_id    in varchar2,
        p_plan_type varchar2
    ) return date is
        l_plan_end_date date;
    begin
        for x in (
            select
                max(plan_end_date)   plan_end_date,
                max(plan_start_date) plan_start_date
            from
                account                   a,
                ben_plan_enrollment_setup b
            where
                    a.acc_id = p_acc_id
                and a.acc_id = b.acc_id
                and a.entrp_id = b.entrp_id
                and nvl(sf_ordinance_flag, 'N') != 'Y'
                and product_type = 'FSA'
                and account_status = 1
                and status = 'A'
                and plan_type = p_plan_type
        ) loop
            if trunc(x.plan_end_date) <> to_date ( '12/31/2099', 'mm/dd/yyyy' ) then
                l_plan_end_date := x.plan_end_date;
            else
                for y in (
                    select
                        max(a.period_date) plan_end_date
                    from
                        (
                            with data as (
                                select
                                    level - 1 k
                                from
                                    dual
                                connect by
                                    level <= to_number(to_char(sysdate, 'YYYY')) - to_number(to_char(x.plan_start_date, 'YYYY'))
                            )
                            select
                                period_date
                            from
                                (
                                    select
                                        add_months(x.plan_start_date, k * 12) - 1 period_date
                                    from
                                        data
                                    order by
                                        1
                                )
                            where
                                period_date <= sysdate
                        ) a
                ) loop
                    l_plan_end_date := add_months(y.plan_end_date, 12);
                end loop;
            end if;

            return l_plan_end_date;
        end loop;
    end get_plan_end_date_for_trn_pkg;

end pc_web_er_renewal;
/


-- sqlcl_snapshot {"hash":"580ed5e2019d6991392e6935cbca9d68ed6b8d87","type":"PACKAGE_BODY","name":"PC_WEB_ER_RENEWAL","schemaName":"SAMQA","sxml":""}