create or replace procedure samqa.generate_carriers as

    l_utl_id    utl_file.file_type;
    l_file_name varchar2(3200);
    l_line      varchar2(32000);
    l_sqlerrm   varchar2(32000);
    l_file_id   number;
    l_message   varchar2(32000);
begin
    for x in (
        select
            companycode,
            companyid
        from
            cobra.companies
        where
            companyname in ( 'Advantis Global Inc', 'Lagniappe Broadcasting Inc dba AGM California', 'Alert Enterprise', 'Alpha Net Consulting LLC'
            , 'Associated Mortgage Bankers',
                             'BCRA Resort Services Inc. dba Bacara Resort and Spa', '*Beta Soft Systems Inc. EFF 01.01.13 moved to CP'
                             , 'Bigpoint Inc.', 'Catalyst Biosciences Inc', 'Breathe Technologies Inc.',
                             'C8 MediSensors', 'Carl Warren and Company', 'Central California Child Development Services', 'Citizen Global Inc.'
                             , 'Corel Inc.',
                             'Loews Coronado Bay Resort', 'Daymen US Inc.', 'DevEmployer', 'D.W. Morgan LLC', 'Epitomics Inc.',
                             'Fashion Furniture Rental Inc.', 'Freese and Nichols Inc', 'G2 Technology Inc.', 'Go Kids Inc.', 'HG Fenton'
                             ,
                             'HNL Automotive Inc.', 'Horizon Christian Fellowship', 'Innovative Engineering Systems', 'Image 2000', 'Impresa Aerospace LLC'
                             ,
                             'Loews Santa Monica Beach Hotel', 'Logos Evangelical Seminary', 'Macro Plastics Inc. (CADM)', 'Mashery Inc'
                             , 'McKee Electric',
                             'Metz Fresh LLC (CADM)', 'Miva Merchant', 'Nextep Texas', 'Northbound Treatment Services', 'Blumenthal Distributing Inc dba Office Star Products'
                             ,
                             'Pioneer Aerospace Corporation', 'PivotLink', 'City of Redondo Beach', 'Samsung Medison America Inc. TERMED 01.01.13'
                             , 'San Dimas Medical Group Ended 12.31.12',
                             'Servicon Systems (CADM)', 'Smartzip INC', 'Solar Link International Inc', 'South Lyon Medical Center', 'SupHerb Farms'
                             ,
                             'Suss MicroTec Inc', 'Titmouse Inc. TERMED effective 04.01.13', 'Tule River Tribal Council (CADM)', 'Vavrinek Trine  Day and Co. LLP'
                             , 'Wikimedia Foundation',
                             'Burbank Community YMCA' )
    ) loop
        l_utl_id := utl_file.fopen('REPORT_DIR', 'Carriers'
                                                 || x.companycode
                                                 || '.txt', 'w');

        for xx in (
            select
                carrier_name
            from
                cobra.employer_benefit_plans_v
            where
                companyid = x.companyid
        ) loop
            utl_file.put_line(
                file   => l_utl_id,
                buffer => xx.carrier_name
            );
        end loop;

        utl_file.fclose(file => l_utl_id);
    end loop;
end;
/


-- sqlcl_snapshot {"hash":"0f63d99b16e2b4695d3c04c3a77d7203028a4421","type":"PROCEDURE","name":"GENERATE_CARRIERS","schemaName":"SAMQA","sxml":""}