-- liquibase formatted sql
-- changeset SAMQA:1754373960358 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_bank_recon.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_bank_recon.sql:null:14f1423754cc016c6e88717675a9ac21165f5c80:create

create or replace package body samqa.pc_bank_recon as

  -- HSA uncashed checks from citizen
  --select * from table( pc_bank_recon.get_check_details('144248,144563,144770,145162,145287,145670,145881,145924,145984,146184,147456,147484,147809,147863,148193,148372,148424,148733,148899,148902,148903,149518,149559,149742,149785,151052,151909,153652,153702,154374,154513,154774,154779,154785,154792,154800,154819,154890,154893,155014,155031,155070,155130,155729,155919,155937,155954,156022,156071,156621,156708,156735,157016,157122,157275,157472,158120,158557,159639,159658,159661,159664,159666,159844,161462,161464,161645,161981,162563,162641,163422,164301,164303,164468,165005,165051,166341,166795,166975,166988,167740,167742,167780,16799,16800,16801,16802,168743,168760,168921,169170,16925,169553,169655,169656,169657,169681,169740,169741,170452,17051,170542,170544,170546,170547,170559,170562,170563,172183,172219,172739,172740,173025,173652,173678,174019,174634,174640,175277,175360,175395,175398,175402,175656,176185,176989,177075,177089,177102,177188,177191,177496,177654,177697,178229,178345,178353,178604,178725,178940,178942,179365,180753,180908,181241,181242,181243,181244,181245,181246,181316,181663,181668,182170,182417,183336,183501,183537,183765,184282,184283,185843,185848,185850,185852,185961,186711,187223,187439,187481,187482,187487,187491,187509,187513,187514,187515,187517,187687,187879,188529,188647,188652,188653,188904,189035,190224,190225,190282,190762,191239,191292,191906,191928,192138,192486,192884,192888,192893,192983,192990,193022,193163,193438,193445,193452,193482,193696,193811,193813,194391,194763,195028,195039,195040'))
  --ORDER BY BANK_CHECK_NUMBER ASC
  --FSA uncashed checks from citizen
  --select * from table( pc_bank_recon.get_check_details('190700,191958 ,191970 ,191984 ,192009 ,192024 ,192922 ,193608 ,193615 ,194236 ,195141'))
  --HRA uncashed checks from citizen
  --select * from table( pc_bank_recon.get_check_details('190589,190634,190687,191089,191400,191632,191652,191666,191710,191715,191762,192387,192650,192653,192700,192708,192713,193305,193307,193863,193880,193922,193953,193979,193991,194002,194169,195064' ))

    function get_check_details (
        p_check_list in varchar2
    ) return check_t
        pipelined
        deterministic
    is
        l_record_t check_rec;
    begin
        for x in (
            select
                *
            from
                the (
                    select
                        cast(str2tbl(p_check_list) as varchar2_4000_tbl)
                    from
                        dual
                )
        ) loop
            l_record_t.check_number := null;
            l_record_t.bank_check_number := null;
            l_record_t.status := null;
            l_record_t.note := null;
            l_record_t.claim_id := null;
            l_record_t.acc_num := null;
            for xx in (
                select
                    a.check_number,
                    a.status,
                    a.entity_type,
                    a.entity_id
                from
                    checks a
                where
                    check_number = x.column_value
            ) loop
                l_record_t.check_number := xx.check_number;
                l_record_t.bank_check_number := x.column_value;
                l_record_t.status := xx.status;
                if xx.entity_type in ( 'HSA_CLAIM', 'CLAIMN' ) then
                    for xxx in (
                        select
                            claim_id,
                            pc_person.acc_num(pers_id) acc_num
                        from
                            claimn
                        where
                            claim_id = xx.entity_id
                    ) loop
                        l_record_t.claim_id := xxx.claim_id;
                        l_record_t.acc_num := xxx.acc_num;
                    end loop;
                end if;

                if xx.entity_type = 'EMPLOYER_PAYMENTS' then
                    for xxx in (
                        select
                            a.payment_register_id,
                            a.acc_num,
                            c.employer_payment_id
                        from
                            payment_register  a,
                            employer_payments c
                        where
                                a.payment_register_id = c.payment_register_id
                            and a.payment_register_id = xx.entity_id
                    ) loop
                        l_record_t.claim_id := xxx.employer_payment_id;
                        l_record_t.acc_num := xxx.acc_num;
                    end loop;
                end if;

            end loop;

            if l_record_t.check_number is null then
                l_record_t.note := 'Check Number not found in the system';
            end if;
            pipe row ( l_record_t );
        end loop;
    end get_check_details;

end pc_bank_recon;
/

