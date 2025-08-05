create or replace package body samqa.pc_person is

/*
 Modification
 14.06.2005 mal move allows and payed to PC_FIN
 03.06.2005 mal *FUNCTION payed, PROCEDURE allows
 11.05.2005 mal Rename allow_deductible to allows, Add allow_deductible55
*/
    function get_entrp_name (
        p_pers_id in number
    ) return varchar2 is
        l_name varchar2(3200);
    begin
        select
            name
        into l_name
        from
            person,
            enterprise
        where
                pers_id = p_pers_id
            and person.entrp_id = enterprise.entrp_id;

        return l_name;
    exception
        when others then
            return null;
    end get_entrp_name;

    function get_entrp_id (
        p_acc_id in number
    ) return number is
        l_entrp_id number;
    begin
        select
            a.entrp_id
        into l_entrp_id
        from
            person  a,
            account b
        where
                acc_id = p_acc_id
            and a.pers_id = b.pers_id;

        return l_entrp_id;
    exception
        when others then
            return null;
    end get_entrp_id;

    function get_entrp_from_pers_id (
        p_pers_id in number
    ) return number is
        l_entrp_id number;
    begin
        select
            entrp_id
        into l_entrp_id
        from
            person
        where
            pers_id = p_pers_id;

        return l_entrp_id;
    exception
        when others then
            return null;
    end get_entrp_from_pers_id;

    function pers_fld (
        pers_in in person.pers_id%type,
        fld_in  in varchar2 default 'LAST_NAME'
    ) return varchar2 is
   /* 13.08.2004 mal Creation
   */
        f    varchar2(255) := upper(fld_in);
        stmt varchar2(4000);
        res  varchar2(4000);
        var  varchar2(4000);
    begin
        open pers_cur(pers_in);
        fetch pers_cur into pers_rec;
        close pers_cur;
        open col_cur(f, 'PERSON');
        fetch col_cur into var;
        close col_cur;
        if var is not null then
            if var = 'DATE' then
                execute immediate 'begin pc_person.dummy := TO_CHAR(pc_person.pers_rec.'
                                  || f
                                  || ', date_mask1); END;';
            elsif var = 'NUMBER' then
                execute immediate 'begin pc_person.dummy := pc_person.pers_rec.'
                                  || f
                                  || '; end;';  -- TO_CHAR mask
            else
                execute immediate 'begin pc_person.dummy := pc_person.pers_rec.'
                                  || f
                                  || '; end;';
            end if;

            res := dummy;
        elsif f = 'FULL_NAME' then
            res := pers_rec.first_name || ' ';
            if pers_rec.middle_name is not null then
                res := res
                       || pers_rec.middle_name
                       || '. ';
            end if;

            res := res || pers_rec.last_name;
            if pers_rec.title is not null then
                res := rtrim(pers_rec.title, '.')
                       || '. '
                       || res;
            end if;

        elsif f = 'ADDRESS2' then
            res := pers_rec.city
                   || ', '
                   || pers_rec.state
                   || ' '
                   || pers_rec.zip;
        else
            res := 'Wrong field "'
                   || fld_in
                   || '"';
        end if;

        return ( res );
    exception
        when others then
            return ( f
                     || ' ERROR '
                     || pers_in );
    end pers_fld;

    function acc_card_count (
        dep_id_in in person.pers_id%type
    ) return number is
    begin
        for x in (
            select
                count(*) cnt
            from
                card_debit a,
                person     b
            where
                    a.card_id = b.pers_main
                and b.pers_id = dep_id_in
        ) loop
            return x.cnt;
        end loop;
    end acc_card_count;

-- ??? ??.??????? ?????????? ???-?? INSURE
    function count_insure (
        person_id_in in person.pers_id%type
    ) return number is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            count(1) c
        from
            insure
        where
            pers_id = p_pers_id;

        r1 c1%rowtype;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        close c1;
        return r1.c;
    end count_insure;
-- ??? ??.??????? ?????????? ???-?? DEPENDENT-??
    function count_dependent (
        person_id_in in person.pers_id%type
    ) return number is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            count(1) c
        from
            person
        where
            pers_main = p_pers_id;

        r1 c1%rowtype;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        close c1;
        return r1.c;
    end count_dependent;
-- ??? ??.??????? ?????????? ???-?? CLAIM-??
    function count_claim (
        person_id_in in person.pers_id%type
    ) return number is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            count(1) c
        from
            claim
        where
            pers_id = p_pers_id;

        r1 c1%rowtype;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        close c1;
        return r1.c;
    end count_claim;
-- ??? ??.??????? ?????????? ???-?? CLAIM-??
    function count_claimn (
        person_id_in in person.pers_id%type
    ) return number is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            count(1) c
        from
            claimn
        where
            pers_id = p_pers_id;

        r1 c1%rowtype;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        close c1;
        return r1.c;
    end count_claimn;
-- ??? ??.??????? ?????????? ???-?? ACCOUNT-??
    function count_account (
        person_id_in in person.pers_id%type
    ) return number is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            count(1) c
        from
            account
        where
            pers_id = p_pers_id;

        r1 c1%rowtype;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        close c1;
        return r1.c;
    end count_account;
-- ??? ??.??????? ?????????? ???-?? ???????? ???? ? ???? ?????? ?????
    function count_debit_card (
        person_id_in in person.pers_id%type
    ) return number is

        cursor c1 (
            p_person_id account.acc_id%type
        ) is
        select
            sum(c) c
        from
            (
                select
                    count(*) c
                from
                    card_debit
                where
                        card_id = p_person_id
                    and status in ( 1, 2, 3, 5 )  -- 5 Added by Swamy for Ticket#9904 on 16/06/2021
                    and nvl(to_date(expire_date, 'YYYYMMDD'), sysdate) >= sysdate
                union all
                select
                    count(*) c
                from
                    card_debit
                where
                    card_id in (
                        select
                            pers_id
                        from
                            person
                        where
                            pers_main = p_person_id
                    )
                    and status in ( 1, 2, 3, 5 )  -- 5 Added by Swamy for Ticket#9904 on 16/06/2021
                    and nvl(to_date(expire_date, 'YYYYMMDD'), sysdate) >= sysdate
            );

        r1 c1%rowtype;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        close c1;
        return r1.c;
    end count_debit_card;
-- ??? ??.??????? ?????????? ??. ACCOUNT-? ??? NULL, ???? ???
    function acc_id (
        person_id_in in person.pers_id%type
    ) return account.acc_id%type is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            acc_id
        from
            account
        where
            pers_id = p_pers_id
        union
        select
            acc_id
        from
            account
        where
            pers_id = (
                select
                    pers_main
                from
                    person
                where
                    pers_id = p_pers_id
            );

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.acc_id;
        else
            return null;
        end if;
    end acc_id;
-- ??? ??.??????? ?????????? ??.?????????
    function relat_code (
        person_id_in in person.pers_id%type
    ) return person.relat_code%type is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            relat_code
        from
            person
        where
            pers_id = p_pers_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.relat_code;
        else
            return null;
        end if;
    end relat_code;
-- ??? ??.??????? ?????????? ???? (?????)
    function state (
        person_id_in in person.pers_id%type
    ) return person.state%type is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            state
        from
            person
        where
            pers_id = p_pers_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.state;
        else
            return null;
        end if;
    end state;
-- ??? ??.??????? ?????????? ????? ACCOUNT-?
    function acc_num (
        person_id_in in person.pers_id%type
    ) return account.acc_num%type is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            acc_num
        from
            account
        where
            pers_id = p_pers_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.acc_num;
        else
            return null;
        end if;
    end acc_num;
-- ??? ??.??????? ?????????? ???? ???????? ACCOUNT-?
    function acc_start_date (
        person_id_in in person.pers_id%type
    ) return account.start_date%type is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            start_date
        from
            account
        where
            pers_id = p_pers_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.start_date;
        else
            return null;
        end if;
    end acc_start_date;
-- ??? ??.??????? ?????????? ???? ??????????? ACCOUNT-?
    function acc_reg_date (
        person_id_in in person.pers_id%type
    ) return account.reg_date%type is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            reg_date
        from
            account
        where
            pers_id = p_pers_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.reg_date;
        else
            return null;
        end if;
    end acc_reg_date;
-- ??? ??.??????? ?????????? ???? ???????? ACCOUNT-?
    function acc_end_date (
        person_id_in in person.pers_id%type
    ) return account.end_date%type is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            end_date
        from
            account
        where
            pers_id = p_pers_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.end_date;
        else
            return null;
        end if;
    end acc_end_date;
-- ??? ??.??????? ?????????? ???? ???????? INSURE
    function insure_start_date (
        person_id_in in person.pers_id%type
    ) return insure.start_date%type is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            start_date
        from
            insure
        where
            pers_id = p_pers_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(person_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.start_date;
        else
            return null;
        end if;
    end insure_start_date;
-- ??? ??. ACCOUNT-? ?????????? ??.???????
    function pers_id_from_acc_id (
        acc_id_in in account.acc_id%type
    ) return account.pers_id%type is

        cursor c1 (
            p_acc_id account.acc_id%type
        ) is
        select
            pers_id
        from
            account
        where
            acc_id = p_acc_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(acc_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.pers_id;
        else
            return null;
        end if;
    end pers_id_from_acc_id;
-- ??? ??. CLAIM-? ?????????? ??.???????
    function pers_id_from_claim_id (
        claim_id_in in claim.claim_id%type
    ) return claim.pers_id%type is

        cursor c1 (
            p_claim_id claim.claim_id%type
        ) is
        select
            pers_id
        from
            claim
        where
            claim_id = p_claim_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(claim_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.pers_id;
        else
            return null;
        end if;
    end pers_id_from_claim_id;
-- ??? ??. CLAIM-? ?????????? ??.ACCOUNT-?
    function acc_id_from_claim_id (
        claim_id_in in claim.claim_id%type
    ) return account.acc_id%type is
    begin
        return pc_person.acc_id(pc_person.pers_id_from_claim_id(claim_id_in));
    end acc_id_from_claim_id;
-- ??? ??. CLAIM-? ?????????? ??.???????
    function pers_id_from_claimn_id (
        claimn_id_in in claimn.claim_id%type
    ) return claimn.pers_id%type is

        cursor c1 (
            p_claim_id claimn.claim_id%type
        ) is
        select
            pers_id
        from
            claimn
        where
            claim_id = p_claim_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(claimn_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.pers_id;
        else
            return null;
        end if;
    end pers_id_from_claimn_id;
-- ??? ??. CLAIM-? ?????????? ??.ACCOUNT-?
    function acc_id_from_claimn_id (
        claimn_id_in in claimn.claim_id%type
    ) return account.acc_id%type is
    begin
        return pc_person.acc_id(pc_person.pers_id_from_claimn_id(claimn_id_in));
    end acc_id_from_claimn_id;
-- ??? ??.??????? ?????????? ?????? ?????, ??????????? ??? ???????? ?? ???? ? ???? year_in
    function allow_deductible (
        pers_id_in in person.pers_id%type,
        year_in    in date default sysdate
    ) return number is

        deduc   number;
        add55   number;
        s55     number;
        alow_up number; -- Catch_up
        alow    number;
        cursor c1 is
        select
            trunc(start_date, 'mm') as dstart,
            trunc(end_date, 'mm')   as dend,
            plan_type,
            deductible  -- :238:239:240 :241:242:243:244:245 :246:247 :248:249:250:251 :252:253:254
        from
            insure
        where
            pers_id = pers_id_in;

        r1      c1%rowtype;

    -- add $ ALLOW_CATCH_UP for older 55, but <= 2 persons.
        cursor c55 is
        select
            pers_id,
            pers_main,
            birth_date,
            months_between(
                nvl(year_in, sysdate),
                birth_date
            ) / 12 m55
       --    , GREATEST(0, LEAST(mons, -- not longer, valid insurance
       --  1 + MONTHS_BETWEEN(d2, TRUNC(NVL(BIRTH_DATE, year_in), 'mm')) - 55*12)) AS m55
        from
            person -- for young person m55 = 0
        where -- Slow! NVL(PERS_MAIN, PERS_ID) = PERS_id_in
            pers_id = pers_id_in -- account holder
        order by
            birth_date;

    begin
        open c1;
        fetch c1 into r1;
        close c1;
  /*     d1 := GREATEST (r1.dstart, jany);      -- :255:256:257:258:259:260 :261:262:263:264:265:266:267:268:269 :270:271:272 :273:274:275:276, :277:278:279 :280:281:282:283:284
       d2 := LEAST(NVL(r1.dend, decy), decy); -- :285:286:287:288:289:290:291:292:293 :294:295:296:297:298:299:300:301:302 :303:304:305 :306:307:308:309, :310:311:312 :313:314:315:316:317:318
       mons := 1 + MONTHS_BETWEEN(d2, d1);    -- months valid insurance
       mons := GREATEST(mons, 0); -- :319:320:321:322:323:324:325:326 mons < 0, :327:328:329:330:331:332:333:334 :335:336:337:338:339:340:341:342:343 :344:345:346:347:348:349:350:351 :352:353:354:355:356 :357:358:359:360:361:362:363:364:365 :366:367:368:369
         s55 := 0; fam := 0;
         FOR r55 IN c55 LOOP
           fam := fam + 1;
           s55 := s55 + r55.m55 * alow_up / 12; -- for each month older 55
         END LOOP;
         s55 := LEAST(s55, alow_up * 2); -- limit 2 persons*/

        for r55 in c55 loop
            s55 := r55.m55; -- for each month older 55
        end loop;
       /*IF r1.plan_type = 1 THEN --22/Apr/2015

          alow := Pc_Param.get_value('FAMILY_CONTRIBUTION', year_in);
       ELSE
          alow := Pc_Param.get_value('INDIVIDUAL_CONTRIBUTION', year_in);
       END IF;*/
        if r1.plan_type = 0 then
            alow := pc_param.get_value('INDIVIDUAL_CONTRIBUTION', year_in);
        else
            alow := pc_param.get_value('FAMILY_CONTRIBUTION', year_in);
        end if;

        dbms_output.put_line('age ' || s55);
        if s55 > 55 then
            alow_up := nvl(
                pc_param.get_value('CATCHUP_CONTRIBUTION', year_in),
                1000
            );
        end if;

   --Pc_Fin.allows (pers_id_in, year_in, deduc, add55);
   --RETURN deduc + add55;
        return nvl(alow, 0) + nvl(alow_up, 0);
    end allow_deductible;
-- ??? ??.??????? ?????????? ??????????? ????? ??????? ?? ???????? (?????? 55 ???)
    function allow_deductible55 (
        pers_id_in in person.pers_id%type,
        year_in    in date default sysdate
    ) return number is
        deduc number;
        add55 number;
    begin
        pc_fin.allows(pers_id_in, year_in, deduc, add55);
        return add55;
    end allow_deductible55;
-- ??? ??.??????? ?????????? ?????, ????????? ?? ???? ? ??????? ????
-- ??? ??????? "????????" ?? ?????; ??? ????????, "???????"
    function payed (
        acc_id_in in account.acc_id%type
    ) return number is
    begin
        return pc_fin.receipts(acc_id_in);
    end payed;
-- ??? ??.ACCOUNT-? ????? ???????????? ??????? ?? ?????????
    function def_amount (
        acc_id_in in account.acc_id%type
    ) return account.month_pay%type is

        cursor c1 (
            p_acc_id account.acc_id%type
        ) is
        select
            month_pay
        from
            account
        where
            acc_id = p_acc_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(acc_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.month_pay;
        else
            return null;
        end if;
    end def_amount;
-- ??? ??.ACCOUNT-? ????? ??????? ?? ?????????
    function def_pay_code (
        acc_id_in in account.acc_id%type
    ) return account.pay_code%type is

        cursor c1 (
            p_acc_id account.acc_id%type
        ) is
        select
            pay_code
        from
            account
        where
            acc_id = p_acc_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(acc_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.pay_code;
        else
            return null;
        end if;
    end def_pay_code;
-- ??? ??.??????? ?????????? ????? ???????? CLAIM_CODE
    function get_claim_code (
        id_in in person.pers_id%type
    ) return varchar2 is
    begin
        return rpad(
            pc_lex.char_only(pc_person.pers_fld(id_in)),
            4,
            '_'
        )
               || to_char(sysdate, 'YYYYMMDD');
    end get_claim_code;
-- ??? ??.??????? ?????????? ??.??????? ??? ?????, ????????? ??? ???????????
-- ?? ??????? ???????? ???????. ??? ??.??????? ????????????? ?? ?????????
-- ? ????? ???????? ????? ??? ???????.
    function broker_id_dflt (
        pers_id_in in person.pers_id%type
    ) return account.broker_id%type is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            a.broker_id broker_id
        from
            person  p,
            account a
        where
                a.entrp_id = p.entrp_id  -- ???? ???????????
            and a.broker_id is not null  -- ?????? ??????
            and p.pers_id = p_pers_id    -- ??. ???????
            ;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(pers_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.broker_id;
        else
            return null;
        end if;
    end broker_id_dflt;
-- ??? ??.??????? ?????????? ??.????? ??? ?????, ????????? ??? ???????????
-- ?? ??????? ???????? ???????. ??? ??.????? ????????????? ?? ?????????
-- ? ????? ???????? ????? ??? ???????.
    function plan_code_dflt (
        pers_id_in in person.pers_id%type
    ) return plans.plan_code%type is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            a.plan_code plan_code
        from
            person  p,
            account a
        where
                a.entrp_id = p.entrp_id  -- ???? ???????????
            and a.broker_id is not null  -- ?????? ??????
            and p.pers_id = p_pers_id    -- ??. ???????
            ;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(pers_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.plan_code;
        else
            return 1;
        end if;
    end plan_code_dflt;
-- ??? ??.??????? ?????????? FEE_SETUP ??? ?????, ????????? ??? ???????????
-- ?? ??????? ???????? ???????. ??? FEE_SETUP ???????????? ?? ?????????
-- ? ????? ???????? ????? ??? ???????.
    function fee_setup_dflt (
        pers_id_in   in person.pers_id%type,
        plan_code_in in account.plan_code%type,
        entrp_id_in  in account.entrp_id%type default null
    ) return account.fee_setup%type is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            a.fee_setup fee_setup,
            a.plan_code plan_code
        from
            person  p,
            account a
        where
                a.entrp_id = p.entrp_id  -- ???? ???????????
            and a.broker_id is not null  -- ?????? ??????
            and p.pers_id = p_pers_id    -- ??. ???????
            ;

        r1          c1%rowtype;
        f1          boolean;
        x_fee_setup number;
    begin
        if entrp_id_in is null then
            open c1(pers_id_in);
            fetch c1 into r1;
            f1 := c1%found;
            close c1;
            if f1 --AND plan_code_in = r1.plan_code
             then
                x_fee_setup := r1.fee_setup;
            end if;
        else
            begin
                select
                    nvl(fee_setup, 0)
                into x_fee_setup
                from
                    account
                where
                    entrp_id = entrp_id_in;

            exception
                when no_data_found then
                    raise_application_error('-20001', 'Employer account is not created, please create employer account ');
            end;
        end if;

        if nvl(x_fee_setup, 0) = 0 then
            x_fee_setup := pc_plan.fsetup(plan_code_in);
        end if;

        return x_fee_setup;
    end fee_setup_dflt;
-- ??? ??.??????? ?????????? FEE_MAINT ??? ?????, ????????? ??? ???????????
-- ?? ??????? ???????? ???????. ??? FEE_MAINT ???????????? ?? ?????????
-- ? ????? ???????? ????? ??? ???????.
    function fee_maint_dflt (
        pers_id_in   in person.pers_id%type,
        plan_code_in in account.plan_code%type
    ) return account.fee_maint%type is

        cursor c1 (
            p_pers_id person.pers_id%type
        ) is
        select
            a.fee_maint fee_maint,
            a.plan_code plan_code
        from
            person  p,
            account a
        where
                a.entrp_id = p.entrp_id  -- ???? ???????????
            and a.broker_id is not null  -- ?????? ??????
            and p.pers_id = p_pers_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(pers_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if
            r1.fee_maint is not null
            and plan_code_in = r1.plan_code
        then
            return r1.fee_maint;
        else
            for x in (
                select
                    annual_flag
                from
                    plan_fee_v
                where
                    plan_code = plan_code_in
            ) loop
                if x.annual_flag = 'Y' then
                    return pc_plan.fannual(plan_code_in);
                else
                    return pc_plan.fmonth(plan_code_in);
                end if;
            end loop;
        end if;

        return 0;
    end fee_maint_dflt;
-- ??? ??.????? (ACC_ID) ?????????? max(pay_num) ?? PAYMENT
    function max_pay_num_for_acc_id (
        acc_id_in in payment.acc_id%type
    ) return payment.pay_num%type is

        cursor c1 (
            p_acc_id payment.acc_id%type
        ) is
        select
            nvl(
                max(pay_num),
                0
            ) max_pay_num
        from
            payment
        where
            acc_id = p_acc_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(acc_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.max_pay_num + 1;
        else
            return 1;
        end if;
    end max_pay_num_for_acc_id;
-- ??? ??.claim_? (CLAIM_ID) ?????????? max(pay_num) ?? PAYMENT
    function max_pay_num_for_claim_id (
        claim_id_in in claim.claim_id%type
    ) return payment.pay_num%type is
    begin
        return pc_person.max_pay_num_for_acc_id(pc_person.acc_id_from_claim_id(claim_id_in));
    end max_pay_num_for_claim_id;
-- ??? ??.claim_? (CLAIMN_ID) ?????????? max(pay_num) ?? PAYMENT
    function max_pay_num_for_claimn_id (
        claimn_id_in in claimn.claim_id%type
    ) return payment.pay_num%type is
    begin
        return pc_person.max_pay_num_for_acc_id(pc_person.acc_id_from_claimn_id(claimn_id_in));
    end max_pay_num_for_claimn_id;
-- ??? ??.??????? ?????????? ????????? ?? ?? ????? Debit Card
    function card_allowed (
        person_id_in in person.pers_id%type
    ) return number is

        cursor c1 (
            p_person_id person.pers_id%type
        ) is
        select
            e.card_allowed
        from
            enterprise e,
            person     p
        where
                e.entrp_id = p.entrp_id
            and p.pers_id = p_person_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(nvl(to_number(pc_person.pers_fld(person_id_in, 'PERS_MAIN')),
                    person_id_in));

        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.card_allowed;
        else
            return null;
        end if;
    end card_allowed;

    function acc_balance (
        person_id_in in person.pers_id%type
    ) return number is
        l_balance number := 0;
    begin
        if person_id_in is not null then
            select
                pc_account.acc_balance(acc_id)
            into l_balance
            from
                account
            where
                pers_id = person_id_in;

        else
            return 0;
        end if;

        return l_balance;
    end acc_balance;

    function get_person_name (
        p_pers_id in number
    ) return varchar2 is
        l_name varchar2(3200);
    begin
        select
            first_name
            || ' '
            || last_name
        into l_name
        from
            person
        where
            pers_id = p_pers_id;

        return l_name;
    exception
        when others then
            return null;
    end;

    function get_person_name (
        p_acc_num in varchar2
    ) return varchar2 is
        l_name varchar2(3200);
    begin
        select
            first_name
            || ' '
            || last_name
        into l_name
        from
            person  a,
            account b
        where
                acc_num = upper(p_acc_num)
            and a.pers_id = b.pers_id;

        return l_name;
    exception
        when others then
            return null;
    end get_person_name;

    function get_division_code (
        p_pers_id in number
    ) return varchar2 is
        l_division_code varchar2(3200);
    begin
        select
            division_code
        into l_division_code
        from
            person a
        where
            a.pers_id = p_pers_id;

        return l_division_code;
    exception
        when others then
            return null;
    end get_division_code;

    function get_division_name (
        p_pers_id in number
    ) return varchar2 is
        l_division_name varchar2(3200);
    begin
        select
            division_name
        into l_division_name
        from
            person             a,
            employer_divisions b
        where
                a.pers_id = p_pers_id
            and a.entrp_id = b.entrp_id
            and a.division_code = b.division_code;

        return l_division_name;
    exception
        when others then
            return null;
    end get_division_name;

    function get_carrier_name (
        p_pers_id in number
    ) return varchar2 is
        l_carrier_name varchar2(3200);
    begin
        select
            b.name
        into l_carrier_name
        from
            insure     a,
            enterprise b
        where
                a.pers_id = p_pers_id
            and a.insur_id = b.entrp_id;

        return l_carrier_name;
    exception
        when others then
            return null;
    end get_carrier_name;

    function get_pers_id_for_cobra (
        p_cobra_number in number,
        p_person_type  in varchar2
    ) return number is
        l_pers_id number;
    begin

--- to_char added for COBRA Project 20/06/2022 rprabu COBRA_POINT Project
        for x in (
            select
                pers_id
            from
                person
            where
                    orig_sys_vendor_ref = to_char(p_cobra_number)
                and person_type = p_person_type
        ) loop
            l_pers_id := x.pers_id;
        end loop;

        return l_pers_id;
    exception
        when others then
            return null;
    end get_pers_id_for_cobra;

    function get_orig_sys_ref_for_cobra (
        p_pers_id in number
    ) return varchar2 is
        l_member_id varchar2(255);
    begin
        for x in (
            select
                orig_sys_vendor_ref
            from
                person
            where
                pers_id = p_pers_id
        ) loop
            l_member_id := x.orig_sys_vendor_ref;
        end loop;

        return l_member_id;
    exception
        when others then
            return null;
    end get_orig_sys_ref_for_cobra;

-- Added by Swamy for Ticket#9374 on 01/10/2020
    procedure insert_person_audit (
        pers_id        in number,
        p_old_ssn      in varchar2,
        p_new_ssn      in varchar2,
        p_changed_user in number,
        p_changed_date in date
    ) is
        v_sl_no number := 0;
    begin
        for k in (
            select
                max(sl_no) sl_no
            from
                person_audit
        ) loop
            v_sl_no := nvl(k.sl_no, 0);
        end loop;

        v_sl_no := v_sl_no + 1;
        insert into person_audit (
            pers_id,
            old_ssn,
            new_ssn,
            changed_user,
            changed_date,
            sl_no
        ) values ( pers_id,
                   p_old_ssn,
                   p_new_ssn,
                   p_changed_user,
                   p_changed_date,
                   v_sl_no );

    exception
        when others then
            pc_log.log_error('insert_person_audit OTHERS', 'SQLERRM' || sqlerrm);
    end insert_person_audit;

end pc_person;
/


-- sqlcl_snapshot {"hash":"ba182ae0134e5e763ed4ea2ba587fa461408cecb","type":"PACKAGE_BODY","name":"PC_PERSON","schemaName":"SAMQA","sxml":""}