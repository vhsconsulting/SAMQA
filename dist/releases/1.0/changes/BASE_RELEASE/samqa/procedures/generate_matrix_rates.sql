-- liquibase formatted sql
-- changeset SAMQA:1754374143865 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\generate_matrix_rates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/generate_matrix_rates.sql:null:2ecd3861c1727c89db6cd0ecb9719143adb58719:create

create or replace procedure samqa.generate_matrix_rates as

    l_utl_id    utl_file.file_type;
    l_file_name varchar2(3200);
    l_line      varchar2(32000);
    l_sqlerrm   varchar2(32000);
    l_file_id   number;
    l_message   varchar2(32000);
begin
    for x in (
        select
            *
        from
            cobra.employer_benefit_plans_v
        where
                costtypeid = 2
            and companyname in ( 'Advantis Global Inc', 'Lagniappe Broadcasting Inc dba AGM California', 'Alert Enterprise', 'Alpha Net Consulting LLC'
            , 'Associated Mortgage Bankers',
                                 'BCRA Resort Services Inc. dba Bacara Resort and Spa', '*Beta Soft Systems Inc. EFF 01.01.13 moved to CP'
                                 , 'Bigpoint Inc.', 'Catalyst Biosciences Inc', 'Breathe Technologies Inc.',
                                 'C8 MediSensors', 'Carl Warren and Company', 'Central California Child Development Services', 'Citizen Global Inc.'
                                 , 'Corel Inc.',
                                 'Loews Coronado Bay Resort', 'Daymen US Inc.', 'DevEmployer', 'D.W. Morgan LLC', 'Epitomics Inc.',
                                 'Fashion Furniture Rental Inc.', 'Freese and Nichols Inc', 'G2 Technology Inc.', 'Go Kids Inc.', 'HG Fenton'
                                 ,
                                 'HNL Automotive Inc.', 'Horizon Christian Fellowship', 'Innovative Engineering Systems', 'Image 2000'
                                 , 'Impresa Aerospace LLC',
                                 'Loews Santa Monica Beach Hotel', 'Logos Evangelical Seminary', 'Macro Plastics Inc. (CADM)', 'Mashery Inc'
                                 , 'McKee Electric',
                                 'Metz Fresh LLC (CADM)', 'Miva Merchant', 'Nextep Texas', 'Northbound Treatment Services', 'Blumenthal Distributing Inc dba Office Star Products'
                                 ,
                                 'Pioneer Aerospace Corporation', 'PivotLink', 'City of Redondo Beach', 'Samsung Medison America Inc. TERMED 01.01.13'
                                 , 'San Dimas Medical Group Ended 12.31.12',
                                 'Servicon Systems (CADM)', 'Smartzip INC', 'Solar Link International Inc', 'South Lyon Medical Center'
                                 , 'SupHerb Farms',
                                 'Suss MicroTec Inc', 'Titmouse Inc. TERMED effective 04.01.13', 'Tule River Tribal Council (CADM)', 'Vavrinek Trine  Day and Co. LLP'
                                 , 'Wikimedia Foundation',
                                 'Burbank Community YMCA' )
    ) loop
        l_utl_id := utl_file.fopen('REPORT_DIR', 'Matrix'
                                                 || x.companycode
                                                 || '.txt', 'w');

        if x.companycode in ( '314E', 'ALERT', 'ALTAVISTA', 'ALTOS', 'AMTECH',
                              'ANDOVER', 'BLAIR', 'OFFICESTR', 'BODHTREE', 'YMCA',
                              'CARSEM', 'CDS', 'CCCDS', 'CRMC', 'CHINATOWN',
                              'CINDER', 'CITI', 'CITIZEN', 'CIVICORPS', 'CLIFTON',
                              'COLLAB', 'COMFORT', 'DEMILEC', 'DIGITAL', 'DOCSTOC',
                              'DOCUMENT', 'ERGOBABY', 'FULTON', 'GLOBANET', 'HERCA',
                              'HORNBLOWR', 'LA WORKS', 'iDEA', 'ABC DIGIT', 'IMPRESA',
                              'INFINITE', 'IT SOURCE', 'KOONTZ', 'AGM', 'STACEY',
                              'LIGHT', 'MUNCPAS', 'MASHERY', 'MCKEE', 'MIDVALLEY',
                              'MISSION', 'MONTALVO', 'NEUROSPOR', 'OC INTL', 'PINNACLE',
                              'PRIEBE', 'PRODEGE', 'RandR', 'RADIABEAM', 'RELIABLE',
                              'ROCKYS', 'KIDS', 'SOUTHLYON', 'SPARK', 'SPINE',
                              'START UP', 'STEWARD', 'SUNNY', 'SUPHERB', 'SUSS',
                              'TENNENBM', 'CLINOVO', 'UNITEDWAY', 'URNERS', 'WILSHIRE' ) then
            for xx in (
                select
                    *
                from
                    table ( get_rate_lines(x.companycode, 'Y') )
            ) loop
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => xx.column_value
                );
            end loop;

        else
            for xx in (
                select
                    *
                from
                    table ( get_rate_lines(x.companycode, 'N') )
            ) loop
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => xx.column_value
                );
            end loop;
        end if;

        utl_file.fclose(file => l_utl_id);
    end loop;
end;
/

