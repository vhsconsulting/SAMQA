-- liquibase formatted sql
-- changeset SAMQA:1754374143547 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\dependant_demg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/dependant_demg.sql:null:86a4d396e51a1f5122881176ed059b8a7041d370:create

create or replace procedure samqa.dependant_demg (
    p_acc_num_list in varchar2 default null
) is

    l_utl_id          utl_file.file_type;
    l_file_name       varchar2(3200);
    l_line            varchar2(32000);
    l_card_create_tbl pc_debit_card.hra_ee_creation_tab;
    l_sqlerrm         varchar2(32000);
    l_file_id         number;
    mass_card_create exception;
    no_card_create exception;
    l_card_count      number;
begin
    l_file_name := 'DEP'
                   || p_acc_num_list
                   || 'DEMO.mbi';
    l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

    /*   SELECT a.acc_num employee_id
            , d.bps_acc_num employer_id
	          , bp.ben_plan_name plan_id
            , bp.plan_type
            , '"'||SUBSTR(depe.last_name,1,26)||'"' last_name
            , '"'||SUBSTR(depe.first_name,1,19)||'"' first_name
            , '"'||SUBSTR(depe.middle_name,1,1)||'"' middle_name
            , '"'||b.address||'"' address
            , '"'||b.city||'"' city
            , '"'||b.state||'"' state
            , '"'|| CASE WHEN LENGTH(b.ZIP) < 5 THEN LPAD(b.ZIP,5,'0') ELSE b.ZIP END||'"' zip
            , decode(depe.gender,'M',1,'F',2,0) gender
            , to_char(depe.birth_date,'YYYYMMDD') birth_date
            , depe.drivlic
            , TO_CHAR(bp.plan_start_date,'YYYYMMDD') start_date
            , TO_CHAR(bp.plan_end_date,'YYYYMMDD') end_date
            , TO_CHAR(a.start_date,'YYYYMMDD') effective_date
            , NULL email
	    , null annual_election
	    , null card_id
	    , NULL issue_card
            , dep.pers_id
	    , DECODE(depe.relat_code,2,1,3,2,9,0) relative
            , REPLACE(depe.ssn,'-') ssn
       BULK COLLECT INTO l_card_create_tbl
       FROM   account a
             , person b
             , person depe
             , account d
	     , metavante_outbound dep
             , ben_plan_enrollment_setup bp
       WHERE a.pers_id = b.pers_id
        AND dep.acc_num = a.acc_num
        AND depe.pers_id = dep.pers_id
        AND dep.action = 'DEPENDANT_INSERT'
        AND a.complete_flag = 1
        AND a.account_status =1
        AND a.account_type IN ('FSA','HRA')
       	AND d.entrp_id =b.entrp_id
      	AND a.bps_acc_num IS NOT NULL
       	AND d.acc_num = p_acc_num_list
        AND bp.acc_id = d.acc_id
        AND bp.status = 'A'
        AND bp.plan_end_date > sysdate
        AND bp.plan_type IS NOT NULL;
*/
       /*** Writing IB record now, IB is for employee demographics ***/

    l_card_count := l_card_create_tbl.count;
    l_line := 'IA'
              || ','
              || to_char(l_card_count + 1)
              || ','
              || pc_debit_card.g_edi_password
              || ','
              || 'STL_Import_Dep_Card_Creation'
              || ','
              || 'STL_Result_Dep_Card_Creation'
              || ','
              || 'Standard Result Template';

    utl_file.put_line(
        file   => l_utl_id,
        buffer => l_line
    );
    l_line := null;
    for i in 1..l_card_create_tbl.count loop
        l_line := 'ID'                    -- Record ID
                  || ','
                  || 'T00965'                             -- TPA ID
                  || ','
                  || l_card_create_tbl(i).employer_id     -- Employer ID
                  || ','
                  || l_card_create_tbl(i).employee_id     -- Employee ID
    --            ||','||l_card_create_tbl(i).prefix          -- Prefix
                  || ','
                  || l_card_create_tbl(i).last_name       -- Last Name
                  || ','
                  || l_card_create_tbl(i).first_name      -- First Name
                  || ','
                  || l_card_create_tbl(i).middle_name     -- Middle Name
                  || ','
                  || l_card_create_tbl(i).address         -- Address
                  || ','
                  || l_card_create_tbl(i).city            -- City
                  || ','
                  || l_card_create_tbl(i).state           -- State
                  || ','
                  || l_card_create_tbl(i).zip             -- Zip
                  || ','
                  || 'US'                                 -- Country
                  || ','
                  || l_card_create_tbl(i).dep_id          -- Dependant ID
                  || ','
                  || l_card_create_tbl(i).relative        -- Relation
                  || ',CNEWDEP_'
                  || l_card_create_tbl(i).dep_id    -- Record Tracking Number
                  || ','
                  || l_card_create_tbl(i).birth_date            -- Birth date
                  || ','
                  || l_card_create_tbl(i).ssn;   -- SSN

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
    end loop;

    if l_file_name is not null then
        utl_file.fclose(file => l_utl_id);
    end if;

end dependant_demg;
/

