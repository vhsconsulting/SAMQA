-- liquibase formatted sql
-- changeset SAMQA:1754374068889 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_online_enroll_dml.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_online_enroll_dml.sql:null:f9c8b16afb0462c30b375d84f0d08cb873f8856f:create

create or replace package body samqa.pc_online_enroll_dml is

    function valid_email (
        p_email in varchar2
    ) return varchar2 is
 --cemailregexp constant varchar2(1000) := '^[a-z0-9!#$%&''*+/=?^_`{|}~-]+(\.[a-z0-9!#$%&''*+/=?^_`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+([A-Z]{2}|arpa|biz|com|info|intww|name|net|org|pro|aero|asia|cat|coop|edu|gov|jobs|mil|mobi|museum|pro|tel|travel|post)$';
  --cemailregexp constant varchar2(1000) := '[[:alnum:]]+@[[:alnum:]]+\.[[:alnum:]]';
-- commneted above and added below by joshi for 5293. '-' in domain name is allowed.
        cemailregexp constant varchar2(1000) := '[[:alnum:]]+@([[:alnum:]]+(-?))+\.[[:alnum:]]';
    begin
        if regexp_like(p_email, cemailregexp, 'i') then
            return 'Y';
        else
            return 'N';
        end if;
    exception
        when others then
            return 'N';
    end valid_email;

    function array_fill (
        p_array       varchar2_tbl,
        p_array_count number
    ) return varchar2_tbl is
        l_array varchar2_tbl;
    begin
        for i in 1..p_array_count loop
            if ( p_array.exists(i) ) then
                l_array(i) := p_array(i);
            else
                l_array(i) := null;
            end if;
        end loop;

        return l_array;
    end;

    procedure validate_demographics (
        p_enroll_source        in varchar2,
        p_first_name           in varchar2,
        p_last_name            in varchar2,
        p_middle_name          in varchar2,
        p_title                in varchar2,
        p_gender               in varchar2,
        p_birth_date           in varchar2,
        p_ssn                  in varchar2,
        p_id_type              in varchar2,
        p_id_number            in varchar2,
        p_address              in varchar2,
        p_city                 in varchar2,
        p_state                in varchar2,
        p_zip                  in varchar2,
        p_phone                in varchar2,
        p_email                in varchar2,
        p_health_plan_eff_date in varchar2,
        p_plan_type            in varchar2,
        p_account_type         in varchar2_tbl,
        x_error_message        out varchar2
    ) is
        l_setup_error exception;
        l_dup_count number := 0;
    begin
        if p_birth_date is null then
            x_error_message := 'Birth Date is Required , Enter Birth Date';
            raise l_setup_error;
        end if;
     -- ##9536  Remove the mandatory field prefix by jaggi
--     IF P_GENDER IS NULL THEN
--        X_ERROR_MESSAGE := 'Gender is Required , Select Gender';
--        RAISE l_setup_error;
--     END IF;
        if p_first_name is null then
            x_error_message := 'First Name is Required , Enter First Name';
            raise l_setup_error;
        end if;
        if p_last_name is null then
            x_error_message := 'Last Name is Required , Enter Last Name';
            raise l_setup_error;
        end if;
        if p_address is null then
            x_error_message := 'Address is Required , Enter Address';
            raise l_setup_error;
        end if;
        if p_city is null then
            x_error_message := 'City is Required , Enter City';
            raise l_setup_error;
        end if;
        if p_state is null then
            x_error_message := 'State is Required , Enter State';
            raise l_setup_error;
        end if;
        if p_zip is null then
            x_error_message := 'Postal Code is Required , Enter Postal Code';
            raise l_setup_error;
        end if;

-- ##9536  Remove the mandatory field prefix by jaggi
--     IF  LENGTH(P_GENDER) > 1 THEN
--        X_ERROR_MESSAGE := 'Gender Cannot have more than one character';
--        RAISE l_setup_error;
--     END IF;
        if length(p_middle_name) > 1 then
            x_error_message := 'Middle Name Cannot have more than one character';
            raise l_setup_error;
        end if;

        if is_date(p_birth_date, 'MM/DD/YYYY') = 'N' then
            x_error_message := 'Enter Birth Date in MM/DD/YYYY format';
            raise l_setup_error;
        end if;

        if format_to_date(p_birth_date) not between to_date('01011900', 'MMDDRRRR') and sysdate then
            x_error_message := 'The Birth Date must be between 01/01/1900 and Current Date';
            raise l_setup_error;
        end if;

        if to_date ( p_birth_date, 'MM/DD/RRRR' ) > sysdate then
            x_error_message := 'Birth Date cannot be in future';
            raise l_setup_error;
        end if;
    -- Added by Joshi for Webform. Email is not mandatory
        if p_enroll_source <> 'WEBFORM_ENROLL' then
            if p_email is null then
                x_error_message := 'Enter valid email';
                raise l_setup_error;
            end if;
        end if;

        for i in 1..p_account_type.count loop
            if p_account_type(i) = 'HSA' then
                if p_id_number is null then
                    x_error_message := 'Enter valid ID Number';
                    raise l_setup_error;
                end if;
                if p_health_plan_eff_date is null then
                    x_error_message := 'Enter valid Effective Date of Health Plan , it is required for Health Saving Account';
                    raise l_setup_error;
                end if;
                if is_date(p_health_plan_eff_date, 'MM/DD/YYYY') = 'N' then
                    x_error_message := 'Enter Effective Date of Health Plan in MM/DD/YYYY format';
                    raise l_setup_error;
                end if;

                if p_plan_type is null then
                    x_error_message := 'Enter valid Coverage, it is required for Health Saving Account';
                    raise l_setup_error;
                end if;
            end if;
        end loop;

        if isalphanumeric(p_last_name) is not null then
            x_error_message := ' Special Characters '
                               || isalphanumeric(p_last_name)
                               || ' are not allowed for last name ';
            raise l_setup_error;
        end if;

        if isalphanumeric(p_first_name) is not null then
            x_error_message := ' Special Characters '
                               || isalphanumeric(p_first_name)
                               || ' are not allowed for first name ';
            raise l_setup_error;
        end if;

        if isalphanumeric(p_middle_name) is not null then
            x_error_message := ' Special Characters '
                               || isalphanumeric(p_middle_name)
                               || ' are not allowed for middle name ';
            raise l_setup_error;
        end if;

        if
            p_enroll_source = 'WEBFORM_ENROLL'
            and p_email is not null
        then
            pc_log.log_error('VALIDATE_DEMOGRAPHIC: ', p_email);
            if valid_email(p_email) = 'N' then
                x_error_message := ' Enter valid email ';
                raise l_setup_error;
            end if;

        end if;

        if p_enroll_source <> 'WEBFORM_ENROLL' then
            if valid_email(p_email) = 'N' then
                x_error_message := ' Enter valid email ';
                raise l_setup_error;
            end if;
        end if;

    exception
        when l_setup_error then
            null;
    end validate_demographics;

    procedure validate_beneficiary (
        p_beneficiary_name     in varchar2_tbl,
        p_beneficiary_type     in varchar2_tbl,
        p_beneficiary_relation in varchar2_tbl,
        p_ben_distiribution    in varchar2_tbl,
        x_error_message        out varchar2
    ) is

        l_setup_error exception;
        l_spouse_count    number := 0;
        l_dup_ben_count   number := 0;
        l_primary_dist    number := 0;
        l_contingent_dist number := 0;
        l_dist_ben_name   varchar2_tbl;
        l_ben_name        varchar2_tbl;
    begin
        for i in 1..p_beneficiary_type.count loop
            pc_log.log_error('VALIDATE_BENEFICIARY, P_BENEFICIARY_TYPE('
                             || i
                             || ')',
                             p_beneficiary_type(i));
            pc_log.log_error('VALIDATE_BENEFICIARY, P_BEN_DISTIRIBUTION('
                             || i
                             || ')',
                             p_ben_distiribution(i));
            pc_log.log_error('VALIDATE_BENEFICIARY, P_BENEFICIARY_NAME('
                             || i
                             || ')',
                             p_beneficiary_name(i));
            pc_log.log_error('VALIDATE_BENEFICIARY, P_BENEFICIARY_RELATION('
                             || i
                             || ')',
                             p_beneficiary_relation(i));
            if p_beneficiary_name(i) is not null then
                if
                    p_ben_distiribution(i) is not null
                    and is_number(p_ben_distiribution(i)) = 'N'
                then
                    x_error_message := 'Enter valid value for distribution , distribution cannot contain characters';
                    raise l_setup_error;
                else
                    pc_log.log_error('VALIDATE_BENEFICIARY, P_BEN_DISTIRIBUTION('
                                     || i
                                     || ')', 'P_BEN_DISTIRIBUTION IS NULL');
                    if upper(p_beneficiary_relation(i)) = 'SPOUSE' then
                        l_spouse_count := l_spouse_count + 1;
                    end if;

                    if l_spouse_count > 1 then
                        x_error_message := 'There cannot be two spouse records as Beneficiary';
                        raise l_setup_error;
                    end if;
                    if p_ben_distiribution(i) is null
                       or p_ben_distiribution(i) = '' then
                        x_error_message := 'Enter valid value for distribution , distribution cannot be null';
                        raise l_setup_error;
                    end if;

                    pc_log.log_error('VALIDATE_BENEFICIARY,x_error_message', x_error_message);
                    if is_number(replace(
                        p_ben_distiribution(i),
                        '%'
                    )) = 'Y' then
                        if to_number ( replace(
                            p_ben_distiribution(i),
                            '%'
                        ) ) < 0 then
                            x_error_message := 'Enter valid value for distribution , distribution cannot be zero/negative';
                            raise l_setup_error;
                        end if;
                    end if;

                end if;

                if
                    p_ben_distiribution(i) is null
                    and p_beneficiary_name(i) is not null
                then
                    x_error_message := 'Enter valid value for distribution , distribution cannot be null';
                    raise l_setup_error;
                end if;

                if p_beneficiary_type(i) = '1' then
                    if is_number(replace(
                        p_ben_distiribution(i),
                        '%'
                    )) = 'Y' then
                        l_primary_dist := nvl(l_primary_dist, 0) + to_number ( trim(replace(
                            p_ben_distiribution(i),
                            '%'
                        )) );
                    end if;

                    if l_primary_dist > 100 then
                        x_error_message := 'Distribution cannot exceed 100% for primary beneficiary type';
                        raise l_setup_error;
                    end if;
                else
                    if is_number(p_ben_distiribution(i)) = 'Y' then
                        l_contingent_dist := nvl(l_contingent_dist, 0) + to_number ( trim(replace(
                            p_ben_distiribution(i),
                            '%'
                        )) );
                    end if;

                    if l_contingent_dist > 100 then
                        x_error_message := 'Distribution cannot exceed 100% for contingent beneficiary type';
                        raise l_setup_error;
                    end if;
                end if;

            end if;

        end loop;
    exception
        when l_setup_error then
            pc_log.log_error('VALIDATE_BENEFICIARY,x_error_message', x_error_message);
            null;
    end validate_beneficiary;

    procedure validate_dependent (
        p_ssn                 in varchar2,
        p_dep_first_name      in varchar2_tbl,
        p_dep_middle_name     in varchar2_tbl,
        p_dep_last_name       in varchar2_tbl,
        p_dep_gender          in varchar2_tbl,
        p_dep_birth_date      in varchar2_tbl,
        p_dep_ssn             in varchar2_tbl,
        p_dep_relative        in varchar2_tbl,
        p_dep_debit_card_flag in varchar2_tbl,
        x_error_message       out varchar2
    ) is
        l_setup_error exception;
        l_dep_sp_count number := 0;
    begin
        for i in 1..p_dep_birth_date.count loop
            if
                p_dep_last_name(i) is not null
                and ( p_dep_birth_date(i) is null
                      or to_date ( p_dep_birth_date(i), 'MM/DD/YYYY' ) > sysdate )
            then
                x_error_message := 'Enter valid birth date for dependent '
                                   || p_dep_first_name(i)
                                   || ' '
                                   || p_dep_last_name(i);

                raise l_setup_error;
            end if;
        end loop;

        for i in 1..p_dep_relative.count loop
            if
                p_dep_relative(i) = '2'
                and p_dep_last_name(i) is not null
            then
                l_dep_sp_count := l_dep_sp_count + 1;
            end if;

            if l_dep_sp_count > 1 then
                x_error_message := 'Two dependent spouse cannot be present';
                raise l_setup_error;
            end if;
        end loop;

        for i in 1..p_dep_first_name.count loop
            if isalphanumeric(p_dep_last_name(i)) is not null then
                x_error_message := ' Special Characters '
                                   || isalphanumeric(p_dep_last_name(i))
                                   || ' are not allowed for last name ';
                raise l_setup_error;
            end if;

            if isalphanumeric(p_dep_first_name(i)) is not null then
                x_error_message := ' Special Characters '
                                   || isalphanumeric(p_dep_first_name(i))
                                   || ' are not allowed for first name ';
                raise l_setup_error;
            end if;

            if isalphanumeric(p_dep_middle_name(i)) is not null then
                x_error_message := ' Special Characters '
                                   || isalphanumeric(p_dep_middle_name(i))
                                   || ' are not allowed for middle name ';
                raise l_setup_error;
            end if;

        end loop;

        for i in 1..p_dep_debit_card_flag.count loop
            if
                p_dep_last_name(i) is not null
                and p_dep_debit_card_flag(i) = 'Y'
                and months_between(sysdate,
                                   to_date(p_dep_birth_date(i),
                                   'MM/DD/YYYY')) / 12 < 10
            then
                x_error_message := 'Debit card cannot be ordered for dependent '
                                   || p_dep_first_name(i)
                                   || ' '
                                   || p_dep_last_name(i)
                                   || 'since dependent age is less than 10 years ';

                raise l_setup_error;
            end if;
        end loop;

        for i in 1..p_dep_ssn.count loop
            if
                p_dep_ssn(i) is not null
                and replace(
                    p_dep_ssn(i),
                    '-'
                ) = replace(p_ssn, '-')
            then
                x_error_message := 'Member SSN and Dependent SSN cannot be the same ';
                raise l_setup_error;
            end if;

            if
                ( p_dep_ssn(i) is null
                  or p_dep_ssn(i) like '--' )
                and p_dep_last_name(i) is not null
                and p_dep_debit_card_flag(i) in ( '1', 'Y' )
            then
                x_error_message := 'Enter valid social security number for dependent '
                                   || p_dep_first_name(i)
                                   || ' '
                                   || p_dep_last_name(i)
                                   || ' if a debit card is being requested ';

                raise l_setup_error;
            end if;

        end loop;

    exception
        when l_setup_error then
            null;
        when others then
            null;
    end validate_dependent;

    procedure pc_insert_demographics (
        p_enroll_source        in varchar2,
        p_first_name           in varchar2,
        p_last_name            in varchar2,
        p_middle_name          in varchar2,
        p_title                in varchar2,
        p_gender               in varchar2,
        p_birth_date           in varchar2,
        p_ssn                  in varchar2,
        p_id_type              in varchar2,
        p_id_number            in varchar2,
        p_address              in varchar2,
        p_city                 in varchar2,
        p_state                in varchar2,
        p_zip                  in varchar2,
        p_phone                in varchar2,
        p_email                in varchar2,
        p_carrier_id           in number,
        p_health_plan_eff_date in varchar2,
        p_entrp_id             in varchar2,
        p_account_type         in varchar2_tbl,
        p_user_id              in number,
        p_plan_type            in varchar2,
        p_deductible           in varchar2,
        p_lang_pref            in varchar2,
        p_ip_address           in varchar2,
        p_batch_number         in number,
        x_error_message        out varchar2,
        x_return_status        out varchar2
    ) is

        l_sqlerrm        varchar2(3200);
        l_pers_id        number;
        l_acc_id         number;
        l_bank_acct_id   number;
        l_transaction_id number;
        l_action         varchar2(255);
        l_create_error exception;
        l_setup_error exception;
        l_fraud_account  varchar2(30) := 'N';
        l_return_status  varchar2(30);
        l_error_message  varchar2(3200);
        l_acc_num        varchar2(30);
        l_user_id        number;
        l_account_type   varchar2(30);
        l_deductible     number;
        l_effective_date date;
        l_count          number := 0;
        l_user_count     number := 0;
        l_entrp_id       number;
    begin
        x_return_status := 'S';
        validate_demographics(
            p_enroll_source        => p_enroll_source,
            p_first_name           => p_first_name,
            p_last_name            => p_last_name,
            p_middle_name          => p_middle_name,
            p_title                => p_title,
            p_gender               => p_gender,
            p_birth_date           => p_birth_date,
            p_ssn                  => p_ssn,
            p_id_type              => p_id_type,
            p_id_number            => p_id_number,
            p_address              => p_address,
            p_city                 => p_city,
            p_state                => p_state,
            p_zip                  => p_zip,
            p_phone                => p_phone,
            p_email                => p_email,
            p_health_plan_eff_date => p_health_plan_eff_date,
            p_plan_type            => p_plan_type,
            p_account_type         => p_account_type,
            x_error_message        => x_error_message
        );

        pc_log.log_error('PC_ONLINE_ENROLLMENT.INSERT_DEMOGRAPHICS', x_error_message);
        pc_log.log_error('PC_ONLINE_ENROLLMENT.INSERT_DEMOGRAPHICS,P_ID_TYPE', p_id_type);
        pc_log.log_error('PC_ONLINE_ENROLLMENT.INSERT_DEMOGRAPHICS,P_BIRTH_DATE', p_birth_date);
        pc_log.log_error('PC_ONLINE_ENROLLMENT.INSERT_DEMOGRAPHICS,P_HEALTH_PLAN_EFF_DATE', p_health_plan_eff_date);
        if x_error_message is not null then
            raise l_setup_error;
        end if;
        for i in 1..p_account_type.count loop
            pc_log.log_error('PC_ONLINE_ENROLLMENT.INSERT_DEMOGRAPHICS,P_ACCOUNT_TYPE('
                             || i
                             || ')',
                             p_account_type(i));
            if
                pc_enroll_utility_pkg.is_stacked_account(p_entrp_id, null) = 'Y'
                and p_account_type(i) in ( 'HRA', 'FSA' )
            then
                select
                    count(*)
                into l_count
                from
                    online_enrollment
                where
                        ssn = p_ssn
                    and batch_number = p_batch_number
                    and account_type = 'FSA';

            else
                select
                    count(*)
                into l_count
                from
                    online_enrollment
                where
                        ssn = p_ssn
                    and batch_number = p_batch_number
                    and account_type = p_account_type(i);

            end if;

            if l_count > 0 then
                update online_enrollment
                set
                    first_name = initcap(p_first_name),
                    last_name = initcap(p_last_name),
                    middle_name = substr(p_middle_name, 1, 1),
                    title = p_title,
                    gender = p_gender,
                    birth_date = format_to_date(p_birth_date),
                    ssn = format_ssn(p_ssn),
                    id_type = substr(p_id_type, 1, 1),
                    id_number = p_id_number,
                    address = p_address,
                    city = initcap(p_city),
                    state = upper(p_state),
                    zip = p_zip,
                    phone = p_phone,
                    email = p_email,
                    carrier_id = nvl(p_carrier_id, 0) -- added NVL by Joshi for 5022.
                    ,
                    health_plan_eff_date = nvl(
                        format_to_date(p_health_plan_eff_date),
                        sysdate
                    ),
                    plan_type = decode(p_plan_type, 0, 0, 1) -- Added by jaggi#10456 -- coverage tiers  EE+SPOUSE  EE+CHILDREN  should come as FAMILY
                    ,
                    deductible = nvl(p_deductible,
                                     decode(p_plan_type, 0, 1200, 1, 2400,
                                            1200)),
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                    batch_number = p_batch_number;

            else
                l_entrp_id := null;
                if
                    pc_enroll_utility_pkg.is_stacked_account(p_entrp_id, null) = 'Y'
                    and p_account_type(i) in ( 'HRA', 'FSA' )
                then
                   -- l_entrp_id := pc_entrp.get_entrp_id_from_ein_act(P_ENTRP_ID,'FSA'); commented by Joshi for 12775
                    l_entrp_id := pc_entrp.get_active_entrp_id_from_ein_act(p_entrp_id, 'FSA');  -- Added by Joshi for 12775. active account should be returned.

                else
                   -- l_entrp_id := pc_entrp.get_entrp_id_from_ein_act(P_ENTRP_ID,P_ACCOUNT_TYPE(i));    commented by Joshi for 12775
                    l_entrp_id := pc_entrp.get_active_entrp_id_from_ein_act(p_entrp_id,
                                                                            p_account_type(i)); -- Added by Joshi for 12775. active account should be returned.
                end if;

                insert into online_enrollment (
                    enrollment_id,
                    first_name,
                    last_name,
                    middle_name,
                    title,
                    gender,
                    birth_date,
                    ssn,
                    id_type,
                    id_number,
                    address,
                    city,
                    state,
                    zip,
                    phone,
                    email,
                    carrier_id,
                    health_plan_eff_date,
                    entrp_id,
                    plan_type,
                    deductible,
                    ip_address
           --     ,LANG_PERF
                    ,
                    account_type,
                    batch_number,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    enrollment_source
                ) values ( mass_enrollments_seq.nextval,
                           initcap(p_first_name),
                           initcap(p_last_name),
                           substr(p_middle_name, 1, 1),
                           p_title,
                           p_gender,
                           format_to_date(p_birth_date),
                           format_ssn(p_ssn),
                           substr(p_id_type, 1, 1),
                           p_id_number,
                           p_address,
                           initcap(p_city),
                           upper(p_state),
                           p_zip,
                           p_phone,
                           p_email,
                           nvl(p_carrier_id, 0),
                           nvl(
                               format_to_date(p_health_plan_eff_date),
                               sysdate
                           ),
                           l_entrp_id,
                           decode(p_plan_type, 0, 0, 1) -- Added by jaggi#10456 -- coverage tiers  EE+SPOUSE  EE+CHILDREN  should come as FAMILY
                           ,
                           p_deductible,
                           p_ip_address
             --   ,P_LANG_PERF
                           ,
                           p_account_type(i),
                           p_batch_number,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id
                --,'ENROLLMENT_EXPRESS'
                           ,
                           p_enroll_source  -- Added by Joshi for webfform enrollment
                            );

            end if;

            if p_account_type(i) <> 'HSA' then
                select
                    count(*)
                into l_count
                from
                    online_hfsa_enroll_stage
                where
                        ssn = p_ssn
                    and batch_number = p_batch_number;

                if l_count > 0 then
                    update online_hfsa_enroll_stage
                    set
                        first_name = initcap(p_first_name),
                        last_name = initcap(p_last_name),
                        middle_name = substr(p_middle_name, 1, 1),
                        gender = p_gender,
                        birth_date = format_to_date(p_birth_date),
                        ssn = format_ssn(p_ssn),
                        address = p_address,
                        city = initcap(p_city),
                        state = upper(p_state),
                        zip = p_zip,
                        day_phone = p_phone,
                        email_address = p_email,
                        carrier_id = p_carrier_id
                    where
                        batch_number = p_batch_number;

                else
                    l_entrp_id := null;
                    if pc_enroll_utility_pkg.is_stacked_account(p_entrp_id, null) = 'Y' then
                        l_entrp_id := pc_entrp.get_entrp_id_from_ein_act(p_entrp_id, 'FSA');
                    else
                        l_entrp_id := pc_entrp.get_entrp_id_from_ein_act(p_entrp_id,
                                                                         p_account_type(i));
                    end if;

                    insert into online_hfsa_enroll_stage (
                        enroll_stage_id,
                        first_name,
                        middle_name,
                        last_name,
                        ssn,
                        gender,
                        address,
                        city,
                        state,
                        zip,
                        day_phone,
                        email_address,
                        birth_date,
                        division_code,
                        entrp_id,
                        carrier_id,
                        batch_number,
                        ip_address,
                        creation_date
                    ) values ( mass_enrollments_seq.nextval,
                               p_first_name,
                               p_middle_name,
                               p_last_name,
                               format_ssn(p_ssn),
                               p_gender,
                               p_address,
                               p_city,
                               p_state,
                               p_zip,
                               p_phone,
                               p_email,
                               format_to_date(p_birth_date),
                               null,
                               l_entrp_id,
                               p_carrier_id,
                               p_batch_number,
                               p_ip_address,
                               sysdate );

                end if;

            end if;

        end loop;

    exception
        when l_setup_error then
            rollback;
            x_return_status := 'E';
            pc_log.log_error('PC_ONLINE_ENROLLMENT', x_error_message);
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_ONLINE_ENROLLMENT', x_error_message);
    end pc_insert_demographics;

    procedure insert_user (
        p_batch_number      in number,
        p_ssn               in varchar2,
        p_user_name         in varchar2,
        p_user_password     in varchar2,
        p_password_question in varchar2,
        p_password_answer   in varchar2,
        x_error_message     out varchar2,
        x_return_status     out varchar2
    ) is
        l_setup_error exception;
    begin
        x_return_status := 'S';
        pc_log.log_error('INSERT_USER', 'BATCH nUMBER ' || p_batch_number);
        if p_user_name is null then
            x_error_message := 'Enter valid user name';
            raise l_setup_error;
        end if;
        if p_user_password is null then
            x_error_message := 'Enter valid password';
            raise l_setup_error;
        end if;
        if p_password_question is null then
            x_error_message := 'Enter valid password reminder question';
            raise l_setup_error;
        end if;
        if p_password_answer is null then
            x_error_message := 'Enter valid password reminder answer';
            raise l_setup_error;
        end if;
        x_error_message := pc_users.validate_user(
            p_tax_id       => replace(p_ssn, '-'),
            p_acc_num      => null,
            p_user_type    => 'S',
            p_emp_reg_type => null,
            p_user_name    => p_user_name,
            p_password     => p_user_password
        );

        if x_error_message is not null then
            raise l_setup_error;
        end if;
        update online_enrollment
        set
            user_name = p_user_name,
            user_password = p_user_password,
            password_reminder_question = p_password_question,
            password_reminder_answer = p_password_answer
        where
            batch_number = p_batch_number;

    exception
        when l_setup_error then
            rollback;
            x_return_status := 'E';
            pc_log.log_error('PC_ONLINE_ENROLLMENT', x_error_message);
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := x_error_message;
    end insert_user;

    procedure pc_insert_plan (
        p_batch_number  in number,
        p_plan_code     in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        l_setup_error exception;
    begin
        x_return_status := 'S';
        pc_log.log_error('PC_INSERT_PLAN:plan_code', p_plan_code);
        if p_plan_code is null then
            x_error_message := 'Enter valid plan for Health Savings Account';
            raise l_setup_error;
        end if;
        update online_enrollment
        set
            plan_code = p_plan_code
        where
                batch_number = p_batch_number
            and account_type = 'HSA';

    exception
        when l_setup_error then
            x_return_status := 'E';
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := x_error_message;
    end pc_insert_plan;

    procedure pc_insert_beneficiary (
        p_batch_number         in number,
        p_beneficiary_name     in varchar2_tbl,
        p_beneficiary_type     in varchar2_tbl,
        p_beneficiary_relation in varchar2_tbl,
        p_ben_distiribution    in varchar2_tbl,
        p_ssn                  in varchar2,
        p_user_id              in number,
        x_error_message        out varchar2,
        x_return_status        out varchar2
    ) is
        l_setup_error exception;
        l_beneficiary_type     varchar2_tbl;
        l_beneficiary_relation varchar2_tbl;
        l_ben_distiribution    varchar2_tbl;
        l_dep_debit_card_flag  varchar2_tbl;
        l_beneficiary_name     varchar2_tbl;
    begin
        x_return_status := 'S';
        pc_log.log_error('PC_ONLINE_ENROLLMENT.PC_INSERT_BENEFICIARY:P_SSN', p_ssn);
        l_beneficiary_name := array_fill(p_beneficiary_name, p_beneficiary_name.count);
        l_beneficiary_type := array_fill(p_beneficiary_type, p_beneficiary_name.count);
        l_beneficiary_relation := array_fill(p_beneficiary_relation, p_beneficiary_name.count);
        l_ben_distiribution := array_fill(p_ben_distiribution, p_beneficiary_name.count);
        validate_beneficiary(l_beneficiary_name, l_beneficiary_type, l_beneficiary_relation, l_ben_distiribution, x_error_message);
        pc_log.log_error('PC_ONLINE_ENROLLMENT.PC_INSERT_BENEFICIARY:P_SSN', 'VALIDATE_BENEFICIARY' || x_error_message);
        if x_error_message is not null then
            raise l_setup_error;
        end if;
        delete from mass_enroll_dependant
        where
                batch_number = p_batch_number
            and dep_flag = 'BENEFICIARY'
            and subscriber_ssn = p_ssn;

        for i in 1..l_beneficiary_name.count loop
            insert into mass_enroll_dependant (
                mass_enrollment_id,
                subscriber_ssn,
                first_name,
                middle_name,
                last_name,
                gender,
                birth_date,
                ssn,
                relative,
                dep_flag,
                beneficiary_type,
                beneficiary_relation,
                effective_date,
                distiribution,
                debit_card_flag,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                batch_number,
                account_type
            )      -- Added by Swamy for Ticket#8541 on 10/02/2020
                select
                    mass_enrollments_seq.nextval,
                    p_ssn,
                    null,
                    null,
                    l_beneficiary_name(i),
                    null,
                    null,
                    null,
                    null,
                    'BENEFICIARY',
                    l_beneficiary_type(i),
                    l_beneficiary_relation(i),
                    sysdate,
                    l_ben_distiribution(i),
                    null,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    p_batch_number,
                    'HSA'   -- Hardcoded bcos it was difficult to pass from PHP if there are more than one plan using webform enrollment and only for HSA the beneficiary is applicable, Added by Swamy for Ticket#8541 on 10/02/2020
                from
                    dual
                where
                    decode(
                        l_beneficiary_name(i),
                        null,
                        '-1',
                        '',
                        '-1',
                        l_beneficiary_name(i)
                    ) <> '-1';

        end loop;

    exception
        when l_setup_error then
            x_return_status := 'E';
    end pc_insert_beneficiary;

    procedure pc_insert_dependent (
        p_batch_number    in number,
        p_ssn             in varchar2,
        p_dep_first_name  in varchar2_tbl,
        p_dep_middle_name in varchar2_tbl,
        p_dep_last_name   in varchar2_tbl,
        p_dep_gender      in varchar2_tbl,
        p_dep_birth_date  in varchar2_tbl,
        p_dep_ssn         in varchar2_tbl,
        p_dep_relative    in varchar2_tbl,
        p_account_type    in varchar2_tbl,
        p_user_id         in number,
        x_error_message   out varchar2,
        x_return_status   out varchar2
    ) is

        l_dep_sp_count        number := 0;
        l_setup_error exception;
        l_dep_first_name      varchar2_tbl;
        l_dep_middle_name     varchar2_tbl;
        l_dep_last_name       varchar2_tbl;
        l_dep_gender          varchar2_tbl;
        l_dep_birth_date      varchar2_tbl;
        l_dep_ssn             varchar2_tbl;
        l_dep_relative        varchar2_tbl;
        l_dep_debit_card_flag varchar2_tbl;
        l_account_type        varchar2_tbl;
    begin
        x_return_status := 'S';
        pc_log.log_error('PC_ONLINE_ENROLLMENT.PC_INSERT_DEPENDENT:P_ACCOUNT_TYPE COUNT', p_account_type.count);
        pc_log.log_error('PC_ONLINE_ENROLLMENT.PC_INSERT_DEPENDENT:P_DEP_FIRST_NAME COUNT', p_dep_first_name.count);
        l_dep_first_name := array_fill(p_dep_first_name, p_dep_first_name.count);
        l_dep_middle_name := array_fill(p_dep_middle_name, p_dep_first_name.count);
        l_dep_last_name := array_fill(p_dep_last_name, p_dep_first_name.count);
        l_dep_gender := array_fill(p_dep_gender, p_dep_first_name.count);
        l_dep_birth_date := array_fill(p_dep_birth_date, p_dep_first_name.count);
        l_dep_ssn := array_fill(p_dep_ssn, p_dep_first_name.count);
        l_dep_relative := array_fill(p_dep_relative, p_dep_first_name.count);
--    l_ACCOUNT_TYPE      := array_fill(P_ACCOUNT_TYPE,P_DEP_FIRST_NAME.COUNT);

        pc_log.log_error('PC_ONLINE_ENROLLMENT.PC_INSERT_DEPENDENT:P_SSN', p_ssn);
        pc_log.log_error('PC_ONLINE_ENROLLMENT.PC_INSERT_DEPENDENT:ARRAY COUNT', p_account_type.count);
        delete from mass_enroll_dependant
        where
                batch_number = p_batch_number
            and dep_flag <> 'BENEFICIARY'
            and subscriber_ssn = p_ssn;
     --    AND SSN = FORMAT_SSN(l_DEP_SSN(j));

        for j in 1..p_account_type.count loop
            pc_log.log_error('PC_ONLINE_ENROLLMENT.PC_INSERT_DEPENDENT:l_ACCOUNT_TYPE',
                             p_account_type(j));
            validate_dependent(
                p_ssn                 => p_ssn,
                p_dep_first_name      => l_dep_first_name,
                p_dep_middle_name     => l_dep_middle_name,
                p_dep_last_name       => l_dep_last_name,
                p_dep_gender          => l_dep_gender,
                p_dep_birth_date      => l_dep_birth_date,
                p_dep_ssn             => l_dep_ssn,
                p_dep_relative        => l_dep_relative,
                p_dep_debit_card_flag => l_dep_debit_card_flag,
                x_error_message       => x_error_message
            );

            if x_error_message is not null then
                raise l_setup_error;
            end if;
            for i in 1..l_dep_first_name.count loop
                for x in (
                    select
                        count(*) dep_count
                    from
                        person  per,
                        account acc,
                        person  sub
                    where
                            sub.pers_id = acc.pers_id
                        and per.ssn = format_ssn(l_dep_ssn(i))
                        and sub.ssn = format_ssn(p_ssn)
                        and per.pers_end_date is null
                        and acc.account_type = p_account_type(j)
                        and per.pers_main = sub.pers_id  -- 5395  :Joshi; duplicate dependent ssn should be check within same subscriber
                ) loop
                    if x.dep_count >= 1 then
                        x_error_message := 'Cannot add dependent, Your account already has dependent with same Social Security number '
                        ;
                        raise l_setup_error;
                    end if;
                end loop;

                insert into mass_enroll_dependant (
                    mass_enrollment_id,
                    subscriber_ssn,
                    first_name,
                    middle_name,
                    last_name,
                    gender,
                    birth_date,
                    ssn,
                    relative,
                    dep_flag,
                    beneficiary_type,
                    beneficiary_relation,
                    effective_date,
                    distiribution,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    batch_number,
                    account_type
                )
                    select
                        mass_enrollments_seq.nextval,
                        p_ssn,
                        l_dep_first_name(i),
                        decode(
                            l_dep_middle_name(i),
                            '',
                            null,
                            l_dep_middle_name(i)
                        ),
                        decode(
                            l_dep_last_name(i),
                            '',
                            null,
                            l_dep_last_name(i)
                        ),
                        decode(
                            l_dep_gender(i),
                            'Male',
                            'M',
                            'Female',
                            'F',
                            substr(
                                l_dep_gender(i),
                                1,
                                1
                            )
                        ),
                        l_dep_birth_date(i),
                        format_ssn(l_dep_ssn(i)),
                        l_dep_relative(i),
                        'DEPENDANT',
                        null,
                        null,
                        sysdate,
                        null,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        p_batch_number,
                        p_account_type(j)
                    from
                        dual
                    where
                        decode(
                            l_dep_last_name(i),
                            null,
                            '-1',
                            '',
                            '-1',
                            l_dep_last_name(i)
                        ) <> '-1';

            end loop;

        end loop;

    exception
        when l_setup_error then
            null;
    end pc_insert_dependent;

    procedure pc_insert_hrafsa_plan (
        p_batch_number    in number,
        p_ssn             in varchar2,
        p_ben_plan_id     in varchar2_tbl,
        p_plan_type       in varchar2_tbl,
        p_effective_date  in varchar2_tbl,
        p_annual_election in varchar2_tbl,
        p_pay_contrib     in varchar2_tbl,
        p_pay_cycle       in varchar2_tbl,
        p_pay_date        in varchar2_tbl,
        p_cov_tier_name   in varchar2_tbl,
        p_deductible      in varchar2_tbl,
        p_event_code      in varchar2_tbl,
        x_error_message   out varchar2,
        x_return_status   out varchar2
    ) is

        l_ben_plan_id     varchar2_tbl;
        l_plan_type       varchar2_tbl;
        l_effective_date  varchar2_tbl;
        l_annual_election varchar2_tbl;
        l_pay_contrib     varchar2_tbl;
        l_pay_cycle       varchar2_tbl;
        l_cov_tier_name   varchar2_tbl;
        l_deductible      varchar2_tbl;
        l_event_code      varchar2_tbl;
        l_pay_date        varchar2_tbl;
        l_setup_error exception;
        l_plan_count      number := 0;
    begin
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_INSERT_HRAFSA_PLAN:SSN', p_ssn);
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_INSERT_HRAFSA_PLAN:L_BEN_PLAN_ID.count', p_ben_plan_id.count);
        --  pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_INSERT_HRAFSA_PLAN..DATE',P_EFFECTIVE_DATE(0));

        x_return_status := 'S';
        l_ben_plan_id := array_fill(p_ben_plan_id, p_ben_plan_id.count);
        l_plan_type := array_fill(p_plan_type, p_ben_plan_id.count);
        l_annual_election := array_fill(p_annual_election, p_ben_plan_id.count);
        l_effective_date := array_fill(p_effective_date, p_ben_plan_id.count);
        l_pay_contrib := array_fill(p_pay_contrib, p_ben_plan_id.count);
        l_pay_cycle := array_fill(p_pay_cycle, p_ben_plan_id.count);
        l_cov_tier_name := array_fill(p_cov_tier_name, p_ben_plan_id.count);
        l_deductible := array_fill(p_deductible, p_ben_plan_id.count);
        l_event_code := array_fill(p_event_code, p_ben_plan_id.count);
        l_pay_date := array_fill(p_pay_date, p_ben_plan_id.count);
        for i in 1..l_ben_plan_id.count loop
            pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_INSERT_HRAFSA_PLAN:L_EVENT_CODE('
                             || i
                             || ')',
                             l_event_code(i));
            pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_INSERT_HRAFSA_PLAN:L_EFFECTIVE_DATE('
                             || i
                             || ')',
                             l_effective_date(i));
            if is_date(
                l_effective_date(i),
                'MM/DD/YYYY'
            ) = 'N' then
                x_error_message := 'Enter valid Effective Date in MM/DD/YYYY format for plan type ' || l_plan_type(i);
                raise l_setup_error;
            end if;

            if is_date(
                l_pay_date(i),
                'MM/DD/YYYY'
            ) = 'N' then
                x_error_message := 'Enter valid First Payroll Contribution Date in MM/DD/YYYY format for plan type ' || l_plan_type(i
                );
                raise l_setup_error;
            end if;

            if is_number(l_pay_contrib(i)) = 'N' then
                x_error_message := 'Enter valid Pay Period Contribution for plan type ' || l_plan_type(i);
                raise l_setup_error;
            end if;

            if is_number(l_annual_election(i)) = 'N' then
                x_error_message := 'Enter valid Annual Election for plan type ' || l_plan_type(i);
                raise l_setup_error;
            end if;

            for x in (
                select
                    plan_start_date,
                    plan_end_date,
                    minimum_election,
                    maximum_election,
                    product_type
                from
                    ben_plan_enrollment_setup
                where
                    ben_plan_id = l_ben_plan_id(i)
            ) loop
                if x.plan_start_date > to_date ( l_effective_date(i), 'MM/DD/YYYY' ) then
                    x_error_message := 'Enter Effective date after the Plan Year Start or Same Date as Plan Year Start for plan type ' || l_plan_type
                    (i);
                    raise l_setup_error;
                end if;

                if x.plan_end_date < to_date ( l_effective_date(i), 'MM/DD/YYYY' ) then
                    x_error_message := 'Enter Effective date before the Plan Year End for plan type ' || l_plan_type(i);
                    raise l_setup_error;
                end if;

                if x.product_type = 'FSA' then
                    if l_annual_election(i) < x.minimum_election then
                        x_error_message := 'Enter Annual Election more than the Minimum Election for plan type ' || l_plan_type(i);
                        raise l_setup_error;
                    end if;

                    if l_annual_election(i) > x.maximum_election then
                        x_error_message := 'Enter Annual Election less than the Maximum Election for plan type ' || l_plan_type(i);
                        raise l_setup_error;
                    end if;

                end if;

            end loop;

        end loop;

        select
            count(*)
        into l_plan_count
        from
            online_hfsa_enroll_stage
        where
                batch_number = p_batch_number
            and ssn = p_ssn
            and plan_type is not null;

        if
            l_plan_type.count >= 1
            and l_plan_count = 0
        then
            update online_hfsa_enroll_stage
            set
                plan_type = l_plan_type(1),
                effective_date = to_date(l_effective_date(1),
        'MM/DD/YYYY'),
                annual_election = l_annual_election(1),
                pay_contrb = l_pay_contrib(1),
                pay_cycle = l_pay_cycle(1)
       --     ,  COVG_TIER_NAME    =L_COV_TIER_NAME(1)
                ,
                covg_tier_name = null,
                deductible = null
     --       ,  DEDUCTIBLE       = L_DEDUCTIBLE(1)
                ,
                qual_event_code = l_event_code(1),
                first_payroll_date = l_pay_date(1),
                er_ben_plan_id = l_ben_plan_id(1)
            where
                    batch_number = p_batch_number
                and ssn = p_ssn
                and ( plan_type is null
                      or plan_type = l_plan_type(1) );

        end if;

        select
            count(*)
        into l_plan_count
        from
            online_hfsa_enroll_stage
        where
                batch_number = p_batch_number
            and ssn = p_ssn
            and plan_type is not null;

        if
            l_plan_type.count >= 1
            and l_plan_count >= 1
        then
            for i in 1..l_plan_type.count loop
                update online_hfsa_enroll_stage
                set
                    plan_type = l_plan_type(i),
                    effective_date = to_date(l_effective_date(i),
        'MM/DD/YYYY'),
                    annual_election = l_annual_election(i),
                    pay_contrb = l_pay_contrib(i),
                    pay_cycle = l_pay_cycle(i)
       --     ,  COVG_TIER_NAME    =L_COV_TIER_NAME(1)
                    ,
                    covg_tier_name = null,
                    deductible = null
     --       ,  DEDUCTIBLE       = L_DEDUCTIBLE(1)
                    ,
                    qual_event_code = l_event_code(i),
                    first_payroll_date = l_pay_date(i)
                where
                        batch_number = p_batch_number
                    and ssn = p_ssn
                    and plan_type = l_plan_type(i)
                    and er_ben_plan_id = l_ben_plan_id(i);

                if sql%rowcount = 0 then
                    insert into online_hfsa_enroll_stage (
                        enroll_stage_id,
                        first_name,
                        middle_name,
                        last_name,
                        ssn,
                        gender,
                        address,
                        city,
                        state,
                        zip,
                        day_phone,
                        email_address,
                        birth_date,
                        division_code,
                        entrp_id,
                        carrier_id,
                        batch_number,
                        ip_address,
                        creation_date,
                        plan_type,
                        effective_date,
                        annual_election,
                        pay_contrb,
                        pay_cycle,
                        covg_tier_name,
                        deductible,
                        qual_event_code,
                        first_payroll_date,
                        er_ben_plan_id
                    )
                        select
                            mass_enrollments_seq.nextval,
                            first_name,
                            middle_name,
                            last_name,
                            ssn,
                            gender,
                            address,
                            city,
                            state,
                            zip,
                            phone,
                            email,
                            birth_date,
                            division_code,
                            entrp_id,
                            carrier_id,
                            batch_number,
                            ip_address,
                            creation_date,
                            l_plan_type(i),
                            to_date(l_effective_date(i),
                                    'MM/DD/RRRR'),
                            l_annual_election(i),
                            l_pay_contrib(i),
                            l_pay_cycle(i)
       --     ,  COVG_TIER_NAME    =L_COV_TIER_NAME(1)
                            ,
                            null,
                            null
     --       ,  DEDUCTIBLE       = L_DEDUCTIBLE(1)
                            ,
                            l_event_code(i),
                            l_pay_date(i),
                            l_ben_plan_id(i)
                        from
                            online_enrollment
                        where
                                batch_number = p_batch_number
                            and ssn = p_ssn
                            and account_type in ( 'HRA', 'FSA' )
                            and rownum = 1;

                end if;

            end loop;
        end if;

    exception
        when l_setup_error then
            x_return_status := 'E';
        when others then
            pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_INSERT_HRAFSA_PLAN:SQLERRM', sqlerrm);
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end pc_insert_hrafsa_plan;

    procedure pc_insert_coverage (
        p_batch_number  in number,
        p_ssn           in varchar2,
        p_ben_plan_id   in varchar2_tbl,
        p_coverage_type in varchar2_tbl
    ) is
        l_ben_plan_id   varchar2_tbl;
        l_cov_tier_name varchar2_tbl;
        l_setup_error exception;
        l_plan_count    number := 0;
    begin
        pc_log.log_error('PC_ONLINE_ENROLL_DML.pc_insert_coverage:SSN', p_ssn);
        pc_log.log_error('PC_ONLINE_ENROLL_DML.pc_insert_coverage:L_BEN_PLAN_ID.count', p_ben_plan_id.count);
        l_ben_plan_id := array_fill(p_ben_plan_id, p_ben_plan_id.count);
        l_cov_tier_name := array_fill(p_coverage_type, p_ben_plan_id.count);

       --X_RETURN_STATUS := 'S';

        for i in 1..l_cov_tier_name.count loop
            update online_hfsa_enroll_stage
            set
                covg_tier_name = l_cov_tier_name(i)
            where
                    batch_number = p_batch_number
                and ssn = p_ssn
                and er_ben_plan_id = l_ben_plan_id(i);

        end loop;

    end pc_insert_coverage;

    procedure process_enrollment (
        p_batch_number           in number,
        p_enroll_source          in varchar2,
        p_entrp_id               in varchar2,
        p_account_type           in varchar2_tbl,
        p_id_verification_status in varchar2,
        p_transaction_id         in number,
        p_verification_date      in varchar2,
        p_user_id                in number,
        x_error_message          out varchar2,
        x_return_status          out varchar2
    ) is

        l_created_user_id number;
        l_create_error exception;
        l_entrp_id        number;
        l_account_type    varchar2(30);
        n                 number;
        l_hsa_exist       varchar2(1) := 'N';
        l_fsa_exist       varchar2(1) := 'N';
        l_hra_exist       varchar2(1) := 'N';
        x_file_upload_id  number; -- 7919 rprabu 09/08/2019

    begin
        x_return_status := 'S';
        pc_log.log_error('PC_ONLINE_ENROLL_DML', 'p_entrp_id' || p_entrp_id);
        for i in 1..p_account_type.count loop
            if p_account_type(i) = 'HSA' then
                l_hsa_exist := 'Y';
            end if;
            if p_account_type(i) = 'HRA' then
                l_hra_exist := 'Y';
            end if;
            if p_account_type(i) = 'FSA' then
                l_fsa_exist := 'Y';
            end if;
        end loop;

        if l_hsa_exist = 'Y' then
            pc_hsa_batch_enrollment(
                p_batch_number           => p_batch_number,
                p_entrp_id               => pc_entrp.get_entrp_id_from_ein_act(p_entrp_id, 'HSA'),
                p_file_name              => null,
                p_lang_perf              => 'ENGLISH',
                p_user_id                => p_user_id,
                p_id_verification_status => p_id_verification_status,
                p_transaction_id         => p_transaction_id,
                p_verification_date      => p_verification_date,
                x_error_message          => x_error_message,
                x_return_status          => x_return_status
            );

            if x_return_status <> 'S' then
                pc_log.log_error('PC_ONLINE_ENROLL_DML.PROCESS_ENROLLMENT', 'pc_hsa_batch_enrollment:x_error_message' || x_error_message
                );
                raise l_create_error;
            end if;

            process_dependent(
                p_batch_number  => p_batch_number,
                p_account_type  => 'HSA',
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );

            pc_log.log_error('PC_ONLINE_ENROLL_DML.PROCESS_ENROLLMENT', 'PROCESS_DEPENDENT:x_error_message' || x_error_message);
        end if;

        if (
            l_hra_exist = 'Y'
            and l_fsa_exist = 'Y'
        )
        or (
            l_hra_exist = 'N'
            and l_fsa_exist = 'Y'
        ) then
            l_account_type := 'FSA';
        end if;

        if (
            l_hra_exist = 'Y'
            and l_fsa_exist = 'N'
        ) then
            l_account_type := 'HRA';
        end if;

        if
            l_account_type in ( 'FSA', 'HRA' )
            and ( l_hra_exist = 'Y'
            or l_fsa_exist = 'Y' )
        then
            for x in (
                select
                    b.entrp_id
                from
                    enterprise a,
                    account    b
                where
                        replace(a.entrp_code, '-') = p_entrp_id
                    and a.entrp_id = b.entrp_id
                    and b.account_type in ( 'HRA', 'FSA' )
                    and b.account_status = 1
            )  -- added by Joshi for 11021
             loop
                l_entrp_id := x.entrp_id;
            end loop;

            pc_online_enrollment.pc_hrafsa_emp_batch_enrollment(
                p_batch_number   => p_batch_number,
                p_entrp_id       => l_entrp_id,
                p_file_name      => null,
                p_lang_perf      => 'ENGLISH',
                p_user_id        => p_user_id
              --,p_enroll_source   => 'ENROLLMENT_EXPRESS'
                ,
                p_enroll_source  => p_enroll_source -- commented above and add this line Joshi webform
                ,
                p_process_type   => null 					 --- Added by rprabu on 30/07/2019 for 7919
                ,
                p_file_upload_id => x_file_upload_id         --- Added by rprabu on 30/07/2019 for 7919
                ,
                x_error_message  => x_error_message,
                x_return_status  => x_return_status
            );
           -- pc_log.log_error('PC_ONLINE_ENROLL_DML.PROCESS_ENROLLMENT','after calling pc_hrafsa_emp_batch_enrollment :x_error_message'||x_error_message);
            if x_return_status = 'S' then
                for x in (
                    select
                        a.acc_id,
                        b.plan_type,
                        a.enrollment_id,
                        b.life_event_code,
                        c.pers_id
                    from
                        online_enrollment   a,
                        online_enroll_plans b,
                        account             c
                    where
                            a.batch_number = p_batch_number
                        and a.account_type in ( 'HRA', 'FSA' )
                        and c.acc_id = a.acc_id
                        and a.enrollment_id = b.enrollment_id
                ) loop
                    update ben_plan_enrollment_setup
                    set
                        life_event_code = x.life_event_code
                    where
                            acc_id = x.acc_id
                        and plan_type = x.plan_type
                        and batch_number = p_batch_number;
                   -- if any dependent card is ordered in the process we want to make sure they are in pendng activation
                    update card_debit
                    set
                        status = 9
                    where
                        card_id in (
                            select
                                pers_id
                            from
                                person
                            where
                                pers_main = x.pers_id
                        );

                end loop;
            else
                pc_log.log_error('PC_ONLINE_ENROLL_DML.PROCESS_ENROLLMENT', 'PROCESS_DEPENDENT:x_error_message' || x_error_message);
                raise l_create_error;
            end if;
          -- Added By Joshi for webform enrollment.
          -- commented by Joshi below as per 5026. process dependent for webform enrollment
          --IF p_enroll_source <> 'WEBFORM_ENROLL' THEN
            process_dependent(
                p_batch_number  => p_batch_number,
                p_account_type  => l_account_type,
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );
           -- END IF;

            pc_log.log_error('PC_ONLINE_ENROLL_DML.PROCESS_ENROLLMENT', 'after PROCESS_DEPENDENT:x_return_status' || x_return_status)
            ;
        end if;

      -- Added By Joshi for webform enrollment.
        if p_enroll_source <> 'WEBFORM_ENROLL' then
            for x in (
                select distinct
                    user_name,
                    user_password,
                    password_reminder_question,
                    acc_num,
                    email,
                    password_reminder_answer,
                    ssn
                from
                    online_enrollment
                where
                    batch_number = p_batch_number
            ) loop
                if pc_users.check_user_registered(x.ssn, 'S') = 'N' then
                    pc_users.insert_users(
                        p_user_name     => x.user_name,
                        p_password      => x.user_password,
                        p_user_type     => 'S',
                        p_find_key      => x.acc_num,
                        p_email         => x.email,
                        p_pw_question   => x.password_reminder_question,
                        p_pw_answer     => x.password_reminder_answer,
                        p_tax_id        => x.ssn,
                        x_user_id       => l_created_user_id,
                        x_return_status => x_return_status,
                        x_error_message => x_error_message
                    );

                    if x_return_status <> 'S' then
                        pc_log.log_error('PC_ONLINE_ENROLL_DML.PROCESS_ENROLLMENT', 'pc_users.INSERT_USERS:x_error_message' || x_error_message
                        );
                        raise l_create_error;
                    end if;

                else
                    l_created_user_id := pc_users.get_user(x.ssn, 'S');
                    update online_users
                    set
                        user_status = 'A'
                    where
                        user_id = l_created_user_id;

                    for xx in (
                        select
                            user_name
                        from
                            online_users
                        where
                            user_id = l_created_user_id
                    ) loop
                        update online_enrollment
                        set
                            user_name = xx.user_name
                        where
                                batch_number = p_batch_number
                            and ssn = x.ssn;

                    end loop;

                end if;
            end loop;
        end if;
      -- fraud check
        for x in (
            select
                acc_num,
                id_verification_status,
                idv_transaction_id,
                idv_transaction_date
            from
                online_enrollment
            where
                    batch_number = p_batch_number
                and account_type = 'HSA'
        ) loop
            if nvl(x.id_verification_status, -1) <> 0 then
                update online_users
                set
                    blocked = 'Y'
                where
                    user_id = l_created_user_id;

            else
                pc_webservice_batch.process_online_verification(
                    p_acc_num           => x.acc_num,
                    p_transaction_id    => x.idv_transaction_id,
                    p_verification_date => x.idv_transaction_date,
                    x_return_status     => x_return_status,
                    x_error_message     => x_error_message
                );
            end if;
        end loop;

        pc_log.log_error('PC_ONLINE_ENROLL_DML.PROCESS_ENROLLMENT', 'last line ' || x_return_status);
    exception
        when l_create_error then
            x_return_status := 'E';
    end process_enrollment;

    procedure insert_file_history (
        p_batch_number   in varchar2,
        p_entrp_id       in varchar2,
        p_file_name      in varchar2,
        p_lang_perf      in varchar2,
        p_user_id        in number,
        x_file_upload_id out number
    ) is
    begin
        if p_file_name is not null then
            insert into file_upload_history (
                file_upload_id,
                entrp_id,
                file_name,
                batch_number,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( file_upload_history_seq.nextval,
                       p_entrp_id,
                       p_file_name,
                       p_batch_number,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id ) returning file_upload_id into x_file_upload_id;

        end if;
    end insert_file_history;

    procedure update_file_results (
        p_batch_number   in varchar2,
        p_entrp_id       in varchar2,
        p_file_name      in varchar2,
        p_lang_perf      in varchar2,
        p_user_id        in number,
        p_file_upload_id in number
    ) is
    begin
        if p_file_name is not null then
            for x in (
                select
                    sum(
                        case
                            when enrollment_status = 'S' then
                                1
                            else
                                0
                        end
                    ) success_cnt,
                    sum(
                        case
                            when nvl(enrollment_status, 'E') <> 'S' then
                                1
                            else
                                0
                        end
                    ) failure_cnt
                from
                    online_enrollment
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
            ) loop
                if
                    x.success_cnt = 0
                    and x.failure_cnt = 0
                then
                    update file_upload_history
                    set
                        file_upload_result = 'Error processing your file, Contact Customer Service'
                    where
                        file_upload_id = p_file_upload_id;

                else
                    update file_upload_history
                    set
                        file_upload_result = 'Successfully Loaded '
                                             || nvl(x.success_cnt, 0)
                                             || ' employees, '
                                             || decode(
                            nvl(x.failure_cnt, 0),
                            0,
                            '',
                            nvl(x.failure_cnt, 0)
                            || ' employees failed to load '
                        )
                    where
                        file_upload_id = p_file_upload_id;

                end if;
            end loop;

        end if;
    end update_file_results;

    procedure validate_hsa_enrollment (
        p_batch_number           in number,
        p_id_verification_status in number,
        x_error_message          out varchar2
    ) is
        l_create_error exception;
    begin
        for x in (
            select
                birth_date,
                first_name,
                last_name,
                middle_name,
                entrp_id,
                format_ssn(ssn) ssn
            from
                online_enrollment
            where
                batch_number = p_batch_number
        ) loop
            if x.birth_date > sysdate then
                x_error_message := x.ssn || ' cannot enroll, Date of birth is in future ';
                raise l_create_error;
            end if;

            if isalphanumeric(x.last_name) is not null then
                x_error_message := ' Special Characters '
                                   || isalphanumeric(x.last_name)
                                   || ' are not allowed for last name ';
                raise l_create_error;
            end if;

            if isalphanumeric(x.first_name) is not null then
                x_error_message := ' Special Characters '
                                   || isalphanumeric(x.first_name)
                                   || ' are not allowed for first name ';
                raise l_create_error;
            end if;

            if isalphanumeric(x.middle_name) is not null then
                x_error_message := ' Special Characters '
                                   || isalphanumeric(x.middle_name)
                                   || ' are not allowed for middle name ';
                raise l_create_error;
            end if;

            if pc_account.check_duplicate(x.ssn, null, null, 'HSA', x.entrp_id) = 'Y' then
                x_error_message := 'You already have an active account, cannot enroll another account ';
                raise l_create_error;
            end if;

        end loop;
    exception
        when l_create_error then
            null;
        when others then
            x_error_message := sqlerrm;
    end validate_hsa_enrollment;

    procedure process_hsa_enrollment (
        p_batch_number           in varchar2,
        p_entrp_id               in varchar2,
        p_file_name              in varchar2,
        p_lang_perf              in varchar2,
        p_id_verification_status in varchar2,
        p_transaction_id         in number,
        p_verification_date      in varchar2,
        p_user_id                in number,
        x_error_message          out varchar2,
        x_return_status          out varchar2
    ) is

        l_sqlerrm         varchar2(3200);
        l_pers_id         number;
        l_acc_id          number;
        l_bank_acct_id    number;
        l_transaction_id  number;
        l_action          varchar2(255);
        l_create_error exception;
        l_return_status   varchar2(30);
        l_error_message   varchar2(3200);
        l_acc_num         varchar2(30);
        l_user_id         number;
        l_created_user_id number;
        l_file_upload_id  number;
        l_card_id         number;
  --  l_user_id        NUMBER;
    begin
        x_return_status := 'S';
        update online_enrollment
        set
            id_verification_status = p_id_verification_status,
            idv_transaction_id = p_transaction_id,
            idv_transaction_date = p_verification_date
        where
                batch_number = p_batch_number
            and account_type = 'HSA';

        for x in (
            select
                initcap(a.first_name)                                      first_name,
                a.middle_name,
                initcap(a.last_name)                                       last_name,
                a.title,
                upper(a.gender)                                            gender,
                format_ssn(a.ssn)                                          ssn,
                a.enrollment_id,
                a.entrp_id,
                a.phone,
                a.email,
                a.plan_code,
                a.health_plan_eff_date,
                a.start_date,
                b.broker_id,
                a.deductible,
                decode(id_type, 'D', id_number)                            drivers_lic,
                decode(id_type, 'P', id_number)                            passport,
                a.address,
                initcap(a.city)                                            city,
                upper(a.state)                                             state,
                a.zip,
                a.birth_date,
                a.plan_type,
                nvl(a.carrier_id,
                    (
                    select
                        entrp_id
                    from
                        enterprise
                    where
                        regexp_like(upper(name),
                                    '\'
                                    || upper(carrier_name)
                                    || '\')
                        and rownum = 1
                ))                                                         carrier_id,
                a.lang_perf,
                a.user_name,
                a.user_password,
                a.password_reminder_question,
                a.password_reminder_answer,
                nvl(a.debit_card_flag, 'N')                                debit_card_flag,
                b.salesrep_id,
                pc_sales_team.get_salesrep_detail(b.entrp_id, 'SECONDARY') am_id  /*Ticket#5461*/,
                case
                    when a.entrp_id is null then
                        '1'
                    else
                        a.id_verification_status
                end                                                        id_verification_status
            from
                online_enrollment a,
                account           b
            where
                    batch_number = p_batch_number
                and enrollment_status is null
                and a.entrp_id = b.entrp_id
                and a.account_type = 'HSA'
        ) loop
            pc_log.log_error('PC_HSA_BATCH_ENROLLMENT', 'processing for  ' || x.ssn);
            pc_log.log_error('PC_HSA_BATCH_ENROLLMENT', 'plan code  ' || x.plan_code);
            savepoint enroll_savepoint;
            begin
                insert into person (
                    pers_id,
                    first_name,
                    middle_name,
                    last_name,
                    birth_date,
                    title,
                    gender,
                    ssn,
                    drivlic,
                    passport,
                    address,
                    city,
                    state,
                    zip,
                    phone_day,
                    email,
                    relat_code,
                    note,
                    entrp_id,
                    person_type,
                    mass_enrollment_id,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( pers_seq.nextval,
                           x.first_name,
                           substr(x.middle_name, 1, 1),
                           x.last_name,
                           x.birth_date,
                           initcap(x.title),
                           x.gender,
                           x.ssn,
                           x.drivers_lic,
                           x.passport,
                           x.address,
                           x.city,
                           x.state,
                           x.zip,
                           x.phone,
                           x.email,
                           1,
                           'Online Enrollment',
                           x.entrp_id,
                           'SUBSCRIBER',
                           x.enrollment_id,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id ) returning pers_id into l_pers_id;

                pc_log.log_error('PC_ONLINE_ENROLLMENT', 'inserted  ' || l_pers_id);
                l_acc_num := pc_account.generate_acc_num(x.plan_code,
                                                         upper(x.state));
            /*** Insert Account, Insurance, Income and Debit Card ****/
                l_action := 'Creating Account';
                insert into account (
                    acc_id,
                    pers_id,
                    acc_num,
                    plan_code,
                    start_date,
                    broker_id,
                    note,
                    fee_setup,
                    fee_maint,
                    reg_date,
                    account_status,
                    complete_flag,
                    signature_on_file,
                    hsa_effective_date,
                    account_type,
                    enrollment_source,
                    salesrep_id,
                    am_id,
                    lang_perf     /*Ticket#5461*/,
                    blocked_flag,
                    id_verified,
                    created_by,
                    last_updated_by
                ) values ( acc_seq.nextval,
                           l_pers_id,
                           l_acc_num,
                           x.plan_code,
                           greatest(
                               nvl(x.health_plan_eff_date, x.start_date),
                               sysdate
                           ),
                           x.broker_id,
                           'Online Enrollment from Enrollment Express',
                           decode(x.entrp_id,
                                  null,
                                  pc_plan.fsetup_online(-1),
                                  nvl(
                               pc_plan.fsetup_custom_rate(x.plan_code, x.entrp_id),
                               least(
                                   pc_plan.fsetup_er(x.entrp_id),
                                   pc_plan.fsetup_online(0)
                               )
                           )),
                           nvl(
                               pc_plan.fmonth_er(x.entrp_id),
                               pc_plan.fmonth(x.plan_code)
                           ),
                           sysdate,
                           3,
                           1,
                           'Y',
                           greatest(
                               nvl(x.health_plan_eff_date, x.start_date),
                               sysdate
                           ),
                           'HSA',
                           'ONLINE',
                           x.salesrep_id,
                           x.am_id  /*Ticket#5461*/,
                           'ENGLISH',
                           decode(x.id_verification_status, '0', 'N', 'Y') -- added for id verification with veratad
                           ,
                           decode(x.id_verification_status, '0', 'Y', 'N'),
                           p_user_id,
                           p_user_id ) returning acc_id into l_acc_id;
           /*** Creating Insurance Information ***/
                insert into insure (
                    pers_id,
                    insur_id,
                    start_date,
                    deductible,
                    note,
                    plan_type,
                    carrier_supported,
                    allow_eob
                ) values ( l_pers_id,
                           nvl(x.carrier_id, 0),
                           greatest(
                               nvl(x.health_plan_eff_date, x.start_date),
                               sysdate
                           ),
                           nvl(x.deductible, 1200),
                           'Online Enrollment  from Enrollment Express',
                           x.plan_type,
                           pc_insure.get_carrier_supported(x.carrier_id),
                           pc_insure.is_eob_allowed(x.entrp_id) );

           /*** Creating Debit Card Information ***/

                if
                    x.debit_card_flag = 'Y'
                    and ( (
                        x.entrp_id is not null
                        and nvl(
                            pc_person.card_allowed(l_pers_id),
                            0
                        ) = 0
                    )
                    or x.entrp_id is null )
                then
                    insert into card_debit (
                        card_id,
                        start_date,
                        emitent,
                        status,
                        note,
                        max_card_value,
                        last_update_date
                    ) values ( l_pers_id,
                               greatest(
                                   nvl(x.health_plan_eff_date, x.start_date),
                                   sysdate
                               ),
                               6763,
                               case
                                   when pc_plan.can_create_card_on_pend(x.plan_code) = 'Y' then
                                       1
                                   else
                                       9
                               end,
                               'Online Enrollment  from Enrollment Express',
                               0,
                               sysdate ) returning card_id into l_card_id;

                end if;

                l_user_id := pc_users.get_user(
                    replace(x.ssn, '-'),
                    'S',
                    null
                );

                if l_user_id is not null then
                    if p_id_verification_status <> '0' then
                        update online_users
                        set
                            blocked = 'Y'
                        where
                            user_id = l_user_id;

                    else
                        pc_webservice_batch.process_online_verification(
                            p_acc_num           => l_acc_num,
                            p_transaction_id    => p_transaction_id,
                            p_verification_date => p_verification_date,
                            x_return_status     => x_return_status,
                            x_error_message     => x_error_message
                        );

                        if l_return_status <> 'S' then
                            raise l_create_error;
                        end if;
                    end if;
                end if;

                update online_enrollment
                set
                    acc_id = l_acc_id,
                    pers_id = l_pers_id,
                    acc_num = l_acc_num,
                    enrollment_status = 'S',
                    error_message = null,
                    fraud_flag = decode(id_verification_status, '0', 'N', 'Y'),
                    user_password = decode(user_name, null, null, user_password),
                    password_reminder_question = decode(user_name, null, null, password_reminder_question)
                where
                    enrollment_id = x.enrollment_id;

		-- Added by Joshi for 6794 : ACN Migration. migrate new standard accounts
                if
                    x.plan_code = 1
                    and pc_acn_migration.is_employer_migrated(x.entrp_id) = 'Y'
                then
                    insert into acn_employee_migration (
                        mig_seq_no,
                        acc_id,
                        pers_id,
                        account_type,
                        emp_acc_id,
                        action_type,
                        subscriber_type,
                        creation_date,
                        created_by
                    ) values ( mig_seq.nextval,
                               l_acc_id,
                               l_pers_id,
                               'HSA',
                               pc_entrp.get_acc_id(x.entrp_id),
                               'I',
                               'E',
                               sysdate,
                               0 );

                end if;
        -- code ends here Joshi.

            exception
                when l_create_error then
                    rollback to savepoint enroll_savepoint;
                    l_error_message := l_action
                                       || ' '
                                       || x_error_message;
           --   x_return_status := 'E';
                    update online_enrollment
                    set
                        error_message = l_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                when others then
                    rollback to savepoint enroll_savepoint;
                    l_error_message := l_action
                                       || ' '
                                       || sqlerrm;
                    x_return_status := 'E';
                    update online_enrollment
                    set
                        error_message = l_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                    pc_log.log_error('PROCESS_HSA_ENROLLMENT:SQLERRM', sqlerrm);
                    raise;
            end;

        end loop;

    exception
        when others then
            rollback;
            pc_log.log_error('PROCESS_HSA_ENROLLMENT:SQLERRM', sqlerrm);
            x_return_status := 'E';
            x_error_message := l_error_message
                               || ' '
                               || sqlerrm;
    end process_hsa_enrollment;

    procedure pc_hsa_batch_enrollment (
        p_batch_number           in varchar2,
        p_entrp_id               in varchar2,
        p_file_name              in varchar2,
        p_lang_perf              in varchar2,
        p_id_verification_status in varchar2,
        p_transaction_id         in number,
        p_verification_date      in varchar2,
        p_user_id                in number,
        x_error_message          out varchar2,
        x_return_status          out varchar2
    ) is

        l_sqlerrm        varchar2(3200);
        l_pers_id        number;
        l_acc_id         number;
        l_bank_acct_id   number;
        l_transaction_id number;
        l_action         varchar2(255);
        l_create_error exception;
        l_return_status  varchar2(30);
        l_error_message  varchar2(3200);
        l_acc_num        varchar2(30);
        l_user_id        number;
        l_file_upload_id number;
    begin
        if p_file_name is not null then
            insert_file_history(
                p_batch_number   => p_batch_number,
                p_entrp_id       => p_entrp_id,
                p_file_name      => p_file_name,
                p_lang_perf      => p_lang_perf,
                p_user_id        => p_user_id,
                x_file_upload_id => l_file_upload_id
            );
        end if;

        process_hsa_enrollment(
            p_batch_number           => p_batch_number,
            p_entrp_id               => p_entrp_id,
            p_file_name              => p_file_name,
            p_lang_perf              => p_lang_perf,
            p_id_verification_status => p_id_verification_status,
            p_transaction_id         => p_transaction_id,
            p_verification_date      => p_verification_date,
            p_user_id                => p_user_id,
            x_error_message          => x_error_message,
            x_return_status          => x_return_status
        );

        if p_file_name is not null then
            update_file_results(
                p_batch_number   => p_batch_number,
                p_entrp_id       => p_entrp_id,
                p_file_name      => p_file_name,
                p_lang_perf      => p_lang_perf,
                p_user_id        => p_user_id,
                p_file_upload_id => l_file_upload_id
            );
        end if;

    exception
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := x_error_message
                               || ' '
                               || sqlerrm;
    end pc_hsa_batch_enrollment;

    procedure process_dependent (
        p_batch_number  in number,
        p_account_type  in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_dep_pers_id number;
        l_dep_count   number := 0;
        l_ben_count   number := 0;
    begin
        x_return_status := 'S'; -- added by Joshi for ticket 5026. (procedure was returning NULL)
        for x in (
            select
                subscriber_ssn,
                a.first_name,
                a.middle_name,
                a.last_name,
                a.gender,
                to_date(a.birth_date, 'MM/DD/YYYY') birth_date,
                a.ssn,
                a.relative,
                a.dep_flag,
                a.beneficiary_type,
                a.beneficiary_relation,
                a.effective_date,
                a.distiribution,
                a.debit_card_flag,
                b.pers_id,
                c.start_date,
                (
                    select
                        status
                    from
                        card_debit
                    where
                        card_id = b.pers_id
                )                                   card_status,
                a.mass_enrollment_id,
                a.account_type
            from
                mass_enroll_dependant a,
                person                b,
                account               d,
                insure                c
            where
                    format_ssn(a.subscriber_ssn) = b.ssn
                and b.pers_id = c.pers_id (+) -- added by joshi for 5026. for webform carrier is not added.
                and d.pers_id = b.pers_id
                and d.account_type = a.account_type
                and a.batch_number = p_batch_number
                and a.last_name is not null
                and a.error_column is null
                and a.error_message is null
                and d.account_status in ( 1, 3 )
                and a.account_type = nvl(p_account_type, a.account_type)   -- Added by swamy for Ticket#8541
                and not exists (
                    select
                        *
                    from
                        person
                    where
                            person.ssn = a.ssn
                        and d.pers_id = person.pers_main
                )
        ) loop
            pc_log.log_error('INSERTING DEPENDANT', x.first_name
                                                    || ' '
                                                    || x.last_name
                                                    || ' '
                                                    || x.birth_date
                                                    || x.dep_flag);

            if upper(x.dep_flag) = 'DEPENDANT' then
                l_dep_count := 0;
                select
                    count(*)
                into l_dep_count
                from
                    person
                where
                        ssn = format_ssn(x.ssn)
                    and pers_main = x.pers_id;

                if l_dep_count = 0 then
                    select
                        count(*)
                    into l_dep_count
                    from
                        person
                    where
                            first_name = x.first_name
                        and last_name = x.last_name
                        and birth_date = x.birth_date
                        and pers_main = x.pers_id;

                end if;

                if l_dep_count = 0 then
                    insert into person (
                        pers_id,
                        first_name,
                        middle_name,
                        last_name,
                        birth_date,
                        gender,
                        ssn,
                        relat_code,
                        note,
                        pers_main,
                        person_type,
                        mass_enrollment_id,
                        card_issue_flag,
                        pers_start_date
                    ) values ( pers_seq.nextval,
                               x.first_name,
                               x.middle_name,
                               x.last_name,
                               x.birth_date,
                               x.gender,
                               trim(x.ssn),
                               to_number(x.relative),
                               'Online Enrollments',
                               x.pers_id,
                               'DEPENDANT',
                               x.mass_enrollment_id,
                               x.debit_card_flag,
                               sysdate ) returning pers_id into l_dep_pers_id;

                    if
                        x.debit_card_flag = 'Y'
                        and nvl(
                            pc_person.card_allowed(x.pers_id),
                            0
                        ) = 0
                    then
                        insert into card_debit (
                            card_id,
                            start_date,
                            emitent,
                            status,
                            note,
                            max_card_value,
                            last_update_date
                        ) values ( l_dep_pers_id,
                                   greatest(x.start_date, sysdate),
                                   6763,
                                   decode(x.card_status, 9, 9, 1),
                                   'Automatic Online Enrollment',
                                   0,
                                   sysdate );

                    end if;

                else
                    update mass_enroll_dependant
                    set
                        error_message = 'Dependent Already exist'
                    where
                        mass_enrollment_id = x.mass_enrollment_id;

                end if;

            end if;

            if
                ( x.dep_flag in ( 'BENEFICIARY', 'Beneficiary' )
                  or (
                    x.dep_flag in ( 'Dependant', 'Dependent' )
                    and x.beneficiary_type is not null
                    and x.distiribution is not null
                ) )
                and x.account_type = 'HSA'
            then
                insert into beneficiary (
                    beneficiary_id,
                    beneficiary_name,
                    beneficiary_type,
                    relat_code,
                    effective_date,
                    pers_id,
                    creation_date,
                    created_by,
                    distribution,
                    note,
                    mass_enrollment_id
                ) values ( beneficiary_seq.nextval,
                           x.last_name,
                           decode(x.beneficiary_type, 'PRIMARY', 1, 'CONTINGENT', 2,
                                  x.beneficiary_type),
                           x.beneficiary_relation,
                           sysdate,
                           x.pers_id,
                           sysdate,
                           421,
                           trim(x.distiribution),
                           'Online Automatic Enrollments',
                           x.mass_enrollment_id );

            end if;

        end loop;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end process_dependent;

    procedure approve_hrafsa_plan (
        p_name            in varchar2_tbl,
        p_ben_plan_id     in varchar2_tbl,
        p_effective_date  in varchar2_tbl,
        p_annual_election in varchar2_tbl,
        p_pay_contrib     in varchar2_tbl,
        p_pay_cycle       in varchar2_tbl,
        p_payroll_date    in varchar2_tbl,
        p_event_code      in varchar2_tbl,
        p_status          in varchar2_tbl,
        p_user_id         in number,
        p_batch_number    in number,
        p_entrp_id        in number,
        x_approval_status out varchar2_tbl
    ) is

        l_ben_plan_id     varchar2_tbl;
        l_status          varchar2_tbl;
        l_effective_date  varchar2_tbl;
        l_annual_election varchar2_tbl;
        l_pay_contrib     varchar2_tbl;
        l_pay_cycle       varchar2_tbl;
        l_event_code      varchar2_tbl;
        l_payroll_date    varchar2_tbl;
        l_approval_status varchar2_tbl;
        l_name            varchar2_tbl;
        l_app_status      varchar2(30) := 'APPROVED';
        l_val_exception exception;
        l_reject_reason   varchar2(3200);
    begin
        pc_log.log_error('APPROVE_HRAFSA_PLAN', 'Start' || p_entrp_id);
        l_ben_plan_id := array_fill(p_ben_plan_id, p_ben_plan_id.count);
        l_annual_election := array_fill(p_annual_election, p_ben_plan_id.count);
        l_effective_date := array_fill(p_effective_date, p_ben_plan_id.count);
        l_pay_contrib := array_fill(p_pay_contrib, p_ben_plan_id.count);
        l_pay_cycle := array_fill(p_pay_cycle, p_ben_plan_id.count);
        l_event_code := array_fill(p_event_code, p_ben_plan_id.count);
        l_status := array_fill(p_status, p_ben_plan_id.count);
        l_payroll_date := array_fill(p_payroll_date, p_ben_plan_id.count);
        l_approval_status := array_fill(p_payroll_date, p_ben_plan_id.count);
        l_name := array_fill(p_name, p_ben_plan_id.count);
        for i in 1..l_ben_plan_id.count loop
            if l_status(i) <> 'P' then
                l_app_status := 'APPROVED';
                l_reject_reason := null;
                insert into ben_plan_approvals (
                    ben_plan_app_id,
                    name,
                    annual_election,
                    effective_date,
                    pay_contrib,
                    first_pay_date,
                    ben_plan_id,
                    entrp_id,
                    batch_number
                ) values ( ben_plan_approvals_seq.nextval,
                           l_name(i),
                           l_annual_election(i),
                           l_effective_date(i),
                           l_pay_contrib(i),
                           l_payroll_date(i),
                           l_ben_plan_id(i),
                           p_entrp_id,
                           p_batch_number );

                pc_log.log_error('APPROVE_HRAFSA_PLAN,l_status',
                                 l_status(i));
                pc_log.log_error('APPROVE_HRAFSA_PLAN,L_EFFECTIVE_DATE',
                                 l_effective_date(i));
                pc_log.log_error('APPROVE_HRAFSA_PLAN,l_annual_election',
                                 l_annual_election(i));
                pc_log.log_error('APPROVE_HRAFSA_PLAN,L_PAYROLL_DATE',
                                 l_payroll_date(i));
                begin
                    if is_number(l_annual_election(i)) = 'N' then
                        l_approval_status(i) := l_name(i)
                                                || ':'
                                                || l_annual_election(i)
                                                || ':'
                                                || l_effective_date(i)
                                                || ':'
                                                || l_pay_contrib(i)
                                                || ':'
                                                || l_payroll_date(i)
                                                || ':Annual Election must be a numeric value';

                        l_app_status := 'REJECTED';
                        l_reject_reason := 'Annual Election must be a numeric value';
                        raise l_val_exception;
                    end if;

                    if is_number(l_pay_contrib(i)) = 'N' then
                        l_approval_status(i) := l_name(i)
                                                || ':'
                                                || l_annual_election(i)
                                                || ':'
                                                || l_effective_date(i)
                                                || ':'
                                                || l_pay_contrib(i)
                                                || ':'
                                                || l_payroll_date(i)
                                                || ': Estimated Pay Period Contribution must be a numeric value';

                        l_app_status := 'REJECTED';
                        l_reject_reason := 'Estimated Pay Period Contribution must be a numeric value';
                        raise l_val_exception;
                    end if;

                    if is_date(
                        l_effective_date(i),
                        'MM/DD/YYYY'
                    ) = 'N' then
                        l_approval_status(i) := l_name(i)
                                                || ':'
                                                || l_annual_election(i)
                                                || ':'
                                                || l_effective_date(i)
                                                || ':'
                                                || l_pay_contrib(i)
                                                || ':'
                                                || l_payroll_date(i)
                                                || ': Effective Date must be in MM/DD/YYYY format';

                        l_app_status := 'REJECTED';
                        l_reject_reason := 'Effective Date must be in MM/DD/YYYY format';
                        raise l_val_exception;
                    end if;

                    if
                        l_payroll_date(i) is not null
                        and is_date(
                            l_payroll_date(i),
                            'MM/DD/YYYY'
                        ) = 'N'
                    then
                        l_approval_status(i) := l_name(i)
                                                || ':'
                                                || l_annual_election(i)
                                                || ':'
                                                || l_effective_date(i)
                                                || ':'
                                                || l_pay_contrib(i)
                                                || ':'
                                                || l_payroll_date(i)
                                                || ': 1st Payroll Contribution Date must be in MM/DD/YYYY format';

                        l_app_status := 'REJECTED';
                        l_reject_reason := '1st Payroll Contribution Date must be in MM/DD/YYYY format';
                        raise l_val_exception;
                    end if;

                    pc_log.log_error('APPROVE_HRAFSA_PLAN,l_app_status', l_app_status);
                    pc_log.log_error('APPROVE_HRAFSA_PLAN,L_REJECT_REASON', l_reject_reason);
                    if
                        l_status(i) = 'A'
                        and l_app_status = 'APPROVED'
                    then
                        for x in (
                            select
                                ee.status,
                                ee.acc_id,
                                er.minimum_election,
                                er.maximum_election,
                                ee.plan_start_date,
                                ee.plan_end_date,
                                ee.plan_type
                            from
                                ben_plan_enrollment_setup ee,
                                ben_plan_enrollment_setup er
                            where
                                    ee.ben_plan_id = l_ben_plan_id(i)
                                and er.ben_plan_id = ee.ben_plan_id_main
                        ) loop
                            if
                                x.plan_start_date <= to_date ( l_effective_date(i), 'MM/DD/YYYY' )
                                and x.plan_end_date >= to_date ( l_effective_date(i), 'MM/DD/YYYY' )
                                and l_annual_election(i) between x.minimum_election and x.maximum_election
                            then
                                l_approval_status(i) := l_name(i)
                                                        || ':'
                                                        || l_annual_election(i)
                                                        || ':'
                                                        || l_effective_date(i)
                                                        || ':'
                                                        || l_pay_contrib(i)
                                                        || ':'
                                                        || l_payroll_date(i)
                                                        || ':Approved';

                                l_app_status := 'APPROVED';
                            else
                                if to_date ( l_effective_date(i), 'MM/DD/YYYY' ) < x.plan_start_date then
                                    l_approval_status(i) := l_name(i)
                                                            || ':'
                                                            || l_annual_election(i)
                                                            || ':'
                                                            || l_effective_date(i)
                                                            || ':'
                                                            || l_pay_contrib(i)
                                                            || ':'
                                                            || l_payroll_date(i)
                                                            || ': Effective Date cannot be before the Plan Start Date';

                                    l_app_status := 'REJECTED';
                                    l_reject_reason := 'Effective Date cannot be before the Plan Start Date';
                                    raise l_val_exception;
                                end if;

                                if to_date ( l_effective_date(i), 'MM/DD/YYYY' ) > x.plan_end_date then
                                    l_approval_status(i) := l_name(i)
                                                            || ':'
                                                            || l_annual_election(i)
                                                            || ':'
                                                            || l_effective_date(i)
                                                            || ':'
                                                            || l_pay_contrib(i)
                                                            || ':'
                                                            || l_payroll_date(i)
                                                            || ': Effective Date cannot be after the Plan End Date';

                                    l_app_status := 'REJECTED';
                                    l_reject_reason := 'Effective Date cannot be after the Plan End Date';
                                end if;

                                if l_annual_election(i) is null then
                                    if pc_lookups.get_meaning(x.plan_type, 'FSA_HRA_PRODUCT_MAP') = 'HRA' then
                                        l_approval_status(i) := l_name(i)
                                                                || ':'
                                                                || l_annual_election(i)
                                                                || ':'
                                                                || l_effective_date(i)
                                                                || ':'
                                                                || l_pay_contrib(i)
                                                                || ':'
                                                                || l_payroll_date(i)
                                                                || ': Enter valid Coverage Amount';

                                        l_app_status := 'REJECTED';
                                        l_reject_reason := 'Enter valid Coverage Amount ';
                                        raise l_val_exception;
                                    else
                                        l_approval_status(i) := l_name(i)
                                                                || ':'
                                                                || l_annual_election(i)
                                                                || ':'
                                                                || l_effective_date(i)
                                                                || ':'
                                                                || l_pay_contrib(i)
                                                                || ':'
                                                                || l_payroll_date(i)
                                                                || ': Enter valid Annual election ';

                                        l_app_status := 'REJECTED';
                                        l_reject_reason := 'Enter valid Annual election ';
                                        raise l_val_exception;
                                    end if;
                                end if;

                                if
                                    l_annual_election(i) > x.maximum_election
                                    and pc_lookups.get_meaning(x.plan_type, 'FSA_HRA_PRODUCT_MAP') = 'FSA'
                                then
                                    l_approval_status(i) := l_name(i)
                                                            || ':'
                                                            || l_annual_election(i)
                                                            || ':'
                                                            || l_effective_date(i)
                                                            || ':'
                                                            || l_pay_contrib(i)
                                                            || ':'
                                                            || l_payroll_date(i)
                                                            || ': Annual Election cannot be more than the Maximum Annual Election defined for the plan'
                                                            ;

                                    l_app_status := 'REJECTED';
                                    l_reject_reason := 'Annual Election cannot be more than the Maximum Annual Election defined for the plan'
                                    ;
                                    raise l_val_exception;
                                end if;

                                if
                                    l_annual_election(i) < x.minimum_election
                                    and pc_lookups.get_meaning(x.plan_type, 'FSA_HRA_PRODUCT_MAP') = 'FSA'
                                then
                                    l_approval_status(i) := l_name(i)
                                                            || ':'
                                                            || l_annual_election(i)
                                                            || ':'
                                                            || l_effective_date(i)
                                                            || ':'
                                                            || l_pay_contrib(i)
                                                            || ':'
                                                            || l_payroll_date(i)
                                                            || ': Annual Election cannot be less than the Minimum Annual Election defined for the plan'
                                                            ;

                                    l_app_status := 'REJECTED';
                                    l_reject_reason := 'Annual Election cannot be less than the Minimum Annual Election defined for the plan'
                                    ;
                                    raise l_val_exception;
                                end if;

                            end if;
                        end loop;

                        pc_log.log_error('APPROVE_HRAFSA_PLAN,l_app_status', l_app_status);
                        pc_log.log_error('APPROVE_HRAFSA_PLAN,L_BEN_PLAN_ID',
                                         l_ben_plan_id(i));
                        if l_app_status = 'APPROVED' then
                            update ben_plan_enrollment_setup
                            set
                                status = 'A',
                                annual_election = l_annual_election(i),
                                effective_date = to_date(l_effective_date(i),
        'MM/DD/YYYY'),
                                life_event_code = l_event_code(i)
                   -- ,   APPROVED_BY =P_USER_ID
                                ,
                                last_updated_by = p_user_id
                            where
                                    ben_plan_id = l_ben_plan_id(i)
                                and status = 'P';

                            update pay_details
                            set
                                first_payroll_date = l_payroll_date(i),
                                pay_contrb = l_pay_contrib(i),
                                pay_cycle = l_pay_cycle(i),
                                last_updated_by = p_user_id
                            where
                                ben_plan_id = l_ben_plan_id(i);

                            update ben_plan_approvals
                            set
                                status = 'A',
                                approved_date = sysdate,
                                approved_by = p_user_id
                            where
                                    ben_plan_id = l_ben_plan_id(i)
                                and batch_number = p_batch_number;

                            for xx in (
                                select
                                    b.pers_id,
                                    a.batch_number
                                from
                                    ben_plan_enrollment_setup a,
                                    account                   b
                                where
                                        a.ben_plan_id = l_ben_plan_id(i)
                                    and a.acc_id = b.acc_id
                            ) loop
                                update card_debit
                                set
                                    status = 1,
                                    start_date = sysdate
                                where
                                        card_id = xx.pers_id
                                    and status = 9;

                                update card_debit
                                set
                                    status = 1,
                                    start_date = sysdate
                                where
                                    card_id in (
                                        select
                                            b.pers_id
                                        from
                                            person b
                                        where
                                            b.pers_main = xx.pers_id
                                    )
                                    and status = 9;

                            end loop;

                        end if;

                    end if;

                    if l_status(i) = 'R' then
                        update ben_plan_enrollment_setup
                        set
                            status = 'R',
                            effective_end_date = sysdate
              --  ,   REJECTED_BY =P_USER_ID
                            ,
                            last_updated_by = p_user_id
                        where
                                ben_plan_id = l_ben_plan_id(i)
                            and status = 'P';

                        l_approval_status(i) := l_name(i)
                                                || ':'
                                                || l_annual_election(i)
                                                || ':'
                                                || l_effective_date(i)
                                                || ':'
                                                || l_pay_contrib(i)
                                                || ':'
                                                || l_payroll_date(i)
                                                || ': Rejected by Employer';

                        l_app_status := 'REJECTED';
                        l_reject_reason := 'Rejected by Employer';
                        update ben_plan_approvals
                        set
                            status = 'R',
                            reject_reason = l_reject_reason,
                            rejected_date = sysdate,
                            rejected_by = p_user_id
                        where
                                ben_plan_id = l_ben_plan_id(i)
                            and batch_number = p_batch_number;

                    end if;

                exception
                    when l_val_exception then
                        update ben_plan_approvals
                        set
                            status = 'E',
                            reject_reason = l_reject_reason
                        where
                                ben_plan_id = l_ben_plan_id(i)
                            and batch_number = p_batch_number;

                        pc_log.log_error('APPROVE_HRAFSA_PLAN,L_REJECT_REASON', l_reject_reason);
                    when others then
                        pc_log.log_error('APPROVE_HRAFSA_PLAN,when others', sqlerrm);
                end;

            end if;
        end loop;
    -- create annual election and pre funded receipt for approved plans
        pc_benefit_plans.process_annual_election(
            p_batch_number => p_batch_number,
            p_user_id      => p_user_id
        );
        x_approval_status := l_approval_status;
    end approve_hrafsa_plan;

    procedure delete_receipts (
        p_ben_plan_id in number
    ) is
        l_sum_check_amount number := 0;
    begin
        for x in (
            select
                batch_number,
                plan_type,
                ben_plan_id_main,
                acc_id
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id = p_ben_plan_id
        ) loop
            delete from income
            where
                        cc_number = (
                            case
                                when fee_code = 11 then
                                    'PC:'
                                when fee_code = 12 then
                                    'AE:'
                            end
                        )
                                    || x.batch_number
                                    || ':'
                                    || x.ben_plan_id_main
                    and plan_type = x.plan_type
                and fee_code in ( 11, 12 )
                and acc_id = x.acc_id;

            for xx in (
                select
                    b.list_bill,
                    a.contributor,
                    b.check_amount - sum(nvl(amount, 0) + nvl(amount_add, 0)) sum_check_amount,
                    b.check_amount,
                    sum(nvl(amount, 0) + nvl(amount_add, 0))                  total_inc_amount
                from
                    income            a,
                    employer_deposits b
                where
                            cc_number = (
                                case
                                    when fee_code = 11 then
                                        'PC:'
                                    when fee_code = 12 then
                                        'AE:'
                                end
                            )
                                        || x.batch_number
                                        || ':'
                                        || x.ben_plan_id_main
                        and a.plan_type = x.plan_type
                    and a.fee_code in ( 11, 12 )
                    and a.list_bill = b.list_bill
                    and a.contributor = b.entrp_id
                    and a.fee_code = b.reason_code
                    and a.plan_type = b.plan_type
                group by
                    b.list_bill,
                    a.contributor,
                    b.check_amount
            ) loop
                if xx.sum_check_amount = 0 then
                    delete from employer_deposits
                    where
                            list_bill = xx.list_bill
                        and entrp_id = xx.contributor;

                else
                    update employer_deposits
                    set
                        check_amount = xx.sum_check_amount,
                        posted_balance = xx.sum_check_amount
                    where
                            list_bill = xx.list_bill
                        and entrp_id = xx.contributor;

                end if;
            end loop;

        end loop;
    end delete_receipts;

    procedure update_debit_card (
        p_batch_number in number,
        p_ssn          in varchar2,
        p_dep_ssn      in varchar2_tbl,
        p_account_type in varchar2_tbl,
        p_debit_card   in varchar2_tbl,
        p_person_type  in varchar2_tbl
    ) is
        l_dep_ssn      varchar2_tbl;
        l_account_type varchar2_tbl;
        l_debit_card   varchar2_tbl;
        l_person_type  varchar2_tbl;
    begin
        pc_log.log_error('enter update debit card ', p_ssn);
        l_dep_ssn := array_fill(p_dep_ssn, p_dep_ssn.count);
        l_account_type := array_fill(p_account_type, p_dep_ssn.count);
        l_debit_card := array_fill(p_debit_card, p_dep_ssn.count);
        l_person_type := array_fill(p_person_type, p_dep_ssn.count);

    --pc_log.log_error('update_debit_card,P_ACCOUNT_TYPE count ',l_account_type.count);
    --pc_log.log_error('update_debit_card,P_DEBIT_CARD count ',l_debit_card.count);
    --pc_log.log_error('update_debit_card,P_PERSON_TYPE count ',l_person_type.count);

        for i in 1..l_person_type.count loop
            pc_log.log_error('update_debit_card,P_SSN', p_ssn);
            pc_log.log_error('update_debit_card,P_PERSON_TYPE',
                             l_person_type(i));
            if l_person_type(i) = 'SUBSCRIBER' then
                for i in 1..p_account_type.count loop
                    update online_enrollment
                    set
                        debit_card_flag = decode(
                            l_debit_card(i),
                            l_account_type(i),
                            'Y',
                            'N'
                        )
                    where
                            ssn = p_ssn
                        and batch_number = p_batch_number;

                    if p_account_type(i) <> 'HSA' then
                        update online_hfsa_enroll_stage
                        set
                            debit_card = decode(
                                l_debit_card(i),
                                l_account_type(i),
                                'Y',
                                'N'
                            )
                        where
                                ssn = p_ssn
                            and batch_number = p_batch_number;

                    end if;

                end loop;

                update online_enrollment
                set
                    debit_card_flag = 'N'
                where
                    debit_card_flag is null
                    and ssn = p_ssn
                    and batch_number = p_batch_number;

                update online_hfsa_enroll_stage
                set
                    debit_card = 'N'
                where
                    debit_card is null
                    and batch_number = p_batch_number;

            end if;

            if l_person_type(i) = 'DEPENDENT' then
                pc_log.log_error('update_debit_card,P_DEPENDENT_SSN',
                                 l_dep_ssn(i));
                pc_log.log_error('update_debit_card,l_ACCOUNT_TYPE',
                                 l_account_type(i));
                pc_log.log_error('update_debit_card,l_DEBIT_CARD',
                                 l_debit_card(i));
                pc_log.log_error('update_debit_card,P_BATCH_NUMBER', p_batch_number);
                update mass_enroll_dependant
                set
                    debit_card_flag = decode(
                        l_debit_card(i),
                        l_account_type(i),
                        'Y',
                        'N'
                    )
                where
                        subscriber_ssn = format_ssn(p_ssn)
                    and account_type = l_account_type(i)
                    and ssn = l_dep_ssn(i)
                    and batch_number = p_batch_number;

                update mass_enroll_dependant
                set
                    debit_card_flag = 'N'
                where
                    debit_card_flag is null
                    and batch_number = p_batch_number;

            end if;

        end loop;

    end update_debit_card;

    procedure delete_plan (
        p_ssn          in varchar2,
        p_batch_number in number,
        p_plan_type    in varchar2_tbl
    ) is
    begin
        pc_log.log_error('delete_plan:p_plan_type.count', p_plan_type.count);
        pc_log.log_error('delete_plan:p_ssn', p_ssn);
        pc_log.log_error('delete_plan:p_batch_number', p_batch_number);
        for i in 1..p_plan_type.count loop
            pc_log.log_error('delete_plan:p_plan_type('
                             || i
                             || ')',
                             p_plan_type(i));
            delete from online_hfsa_enroll_stage
            where
                    ssn = format_ssn(p_ssn)
                and batch_number = p_batch_number
                and er_ben_plan_id = p_plan_type(i);

        end loop;

    end delete_plan;

    procedure pc_add_hrafsa_plan (
        p_batch_number    in number,
        p_acc_id          in varchar2,
        p_ben_plan_id     in varchar2_tbl,
        p_plan_type       in varchar2_tbl,
        p_effective_date  in varchar2_tbl,
        p_annual_election in varchar2_tbl,
        p_pay_contrib     in varchar2_tbl,
        p_pay_cycle       in varchar2_tbl,
        p_pay_date        in varchar2_tbl,
        p_cov_tier_name   in varchar2_tbl,
        p_deductible      in varchar2_tbl,
        p_event_code      in varchar2_tbl,
        p_user_id         in number,
        x_error_message   out varchar2,
        x_return_status   out varchar2
    ) is

        l_ben_plan_id     varchar2_tbl;
        l_plan_type       varchar2_tbl;
        l_effective_date  varchar2_tbl;
        l_annual_election varchar2_tbl;
        l_pay_contrib     varchar2_tbl;
        l_pay_cycle       varchar2_tbl;
        l_cov_tier_name   varchar2_tbl;
        l_deductible      varchar2_tbl;
        l_event_code      varchar2_tbl;
        l_pay_date        varchar2_tbl;
        l_setup_error exception;
        l_plan_count      number := 0;
    begin
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:Start', 'Start');
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:P_PAY_CYCLE', p_pay_cycle.count);
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:P_DEDUCTIBLE', p_deductible.count);
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:P_COV_TIER_NAME', p_cov_tier_name.count);
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:P_COV_TIER_NAME(1)',
                         p_cov_tier_name(1));
        x_return_status := 'S';
        l_ben_plan_id := array_fill(p_ben_plan_id, p_ben_plan_id.count);
        l_plan_type := array_fill(p_plan_type, p_ben_plan_id.count);
        l_annual_election := array_fill(p_annual_election, p_ben_plan_id.count);
        l_effective_date := array_fill(p_effective_date, p_ben_plan_id.count);
        l_pay_contrib := array_fill(p_pay_contrib, p_ben_plan_id.count);
        l_pay_cycle := array_fill(p_pay_cycle, p_ben_plan_id.count);
        l_cov_tier_name := array_fill(p_cov_tier_name, p_ben_plan_id.count);
        l_deductible := array_fill(p_deductible, p_ben_plan_id.count);
        l_event_code := array_fill(p_event_code, p_ben_plan_id.count);
        l_pay_date := array_fill(p_pay_date, p_ben_plan_id.count);
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:l_PAY_CYCLE', l_pay_cycle.count);
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:l_DEDUCTIBLE', l_deductible.count);
        for i in 1..l_ben_plan_id.count loop
            pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:L_EVENT_CODE',
                             l_event_code(i));
            if is_date(
                l_effective_date(i),
                'MM/DD/YYYY'
            ) = 'N' then
                x_error_message := 'Enter valid Effective Date in MM/DD/YYYY format for plan type ' || l_plan_type(i);
                raise l_setup_error;
            end if;

            if
                is_date(
                    l_pay_date(i),
                    'MM/DD/YYYY'
                ) = 'N'
                and pc_lookups.get_meaning(
                    l_plan_type(i),
                    'FSA_HRA_PRODUCT_MAP'
                ) = 'FSA'
            then
                x_error_message := 'Enter valid First Payroll Contribution Date in MM/DD/YYYY format for plan type ' || l_plan_type(i
                );
                raise l_setup_error;
            end if;

            if
                is_number(l_pay_contrib(i)) = 'N'
                and pc_lookups.get_meaning(
                    l_plan_type(i),
                    'FSA_HRA_PRODUCT_MAP'
                ) = 'FSA'
            then
                x_error_message := 'Enter valid Pay Period Contribution for plan type ' || l_plan_type(i);
                raise l_setup_error;
            end if;

            if is_number(l_annual_election(i)) = 'N' then
                x_error_message := 'Enter valid Annual Election for plan type ' || l_plan_type(i);
                raise l_setup_error;
            end if;

            for x in (
                select
                    plan_start_date,
                    plan_end_date,
                    minimum_election,
                    product_type,
                    case
                        when plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                            nvl(maximum_election,
                                pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT',
                                                           plan_type,
                                                           nvl(plan_start_date, sysdate)) * 12)
                        else
                            nvl(maximum_election, 0)
                    end maximum_election
                from
                    ben_plan_enrollment_setup
                where
                    ben_plan_id = l_ben_plan_id(i)
            ) loop
                if x.plan_start_date > to_date ( l_effective_date(i), 'MM/DD/YYYY' ) then
                    x_error_message := 'Enter Effective date after the Plan Year Start or Same Date as Plan Year Start for plan type ' || l_plan_type
                    (i);
                    raise l_setup_error;
                end if;

                if x.plan_end_date < to_date ( l_effective_date(i), 'MM/DD/YYYY' ) then
                    x_error_message := 'Enter Effective date before the Plan Year End for plan type ' || l_plan_type(i);
                    raise l_setup_error;
                end if;

                if x.product_type = 'FSA' then
                    if l_annual_election(i) < x.minimum_election then
                        x_error_message := 'Enter Annual Election more than the Minimum Election for plan type ' || l_plan_type(i);
                        raise l_setup_error;
                    end if;

                    if l_annual_election(i) > x.maximum_election then
                        x_error_message := 'Enter Annual Election less than the Maximum Election for plan type ' || l_plan_type(i);
                        raise l_setup_error;
                    end if;

                end if;

            end loop;

            pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:L_COV_TIER_NAME',
                             l_cov_tier_name(i));
            pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:L_ANNUAL_ELECTION',
                             l_annual_election(i));
            pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:L_BEN_PLAN_ID',
                             l_ben_plan_id(i));
            pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:L_EFFECTIVE_DATE',
                             l_effective_date(i));
            pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:P_ACC_ID', p_acc_id);
            pc_benefit_plans.add_renew_employees(
                p_acc_id          => p_acc_id,
                p_annual_election => l_annual_election(i),
                p_er_ben_plan_id  => l_ben_plan_id(i),
                p_user_id         => p_user_id,
                p_cov_tier_name   => l_cov_tier_name(i),
                p_effective_date  => to_date(l_effective_date(i),
        'MM/DD/YYYY'),
                p_batch_number    => p_batch_number,
                x_return_status   => x_return_status,
                x_error_message   => x_error_message,
                p_status          => 'P',
                p_life_event_code => l_event_code(i)
            );

            pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:x_error_message', x_error_message);
            if x_return_status <> 'S' then
                raise l_setup_error;
            end if;
            if
                l_pay_date(i) is not null
                and l_pay_contrib(i) is not null
            then
                for xx in (
                    select
                        *
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = p_acc_id
                        and ben_plan_id_main = l_ben_plan_id(i)
                        and batch_number = p_batch_number
                ) loop
                    insert into pay_details (
                        pay_detail_id,
                        acc_id,
                        ben_plan_id,
                        first_payroll_date,
                        pay_contrb,
                        no_of_periods,
                        pay_cycle,
                        effective_date,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        ben_plan_id_main
                    ) values ( pay_details_seq.nextval,
                               p_acc_id,
                               xx.ben_plan_id,
                               l_pay_date(i),
                               l_pay_contrib(i),
                               null,
                               l_pay_cycle(i),
                               to_date(l_effective_date(i),
                                       'MM/DD/YYYY'),
                               sysdate,
                               p_user_id,
                               sysdate,
                               p_user_id,
                               l_ben_plan_id(i) );

                end loop;
            end if;

        end loop;

        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:x_error_message', x_error_message);
    exception
        when l_setup_error then
            x_return_status := 'E';
        when others then
            pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_ADD_HRAFSA_PLAN:SQLERRM', sqlerrm);
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end pc_add_hrafsa_plan;

    procedure pc_update_hrafsa_plan (
        p_ben_plan_id     in number,
        p_effective_date  in varchar2,
        p_annual_election in number,
        p_pay_contrib     in number,
        p_pay_cycle       in varchar2,
        p_pay_date        in varchar2,
        p_cov_tier_name   in varchar2,
        p_deductible      in varchar2,
        p_event_code      in varchar2,
        p_user_id         in number,
        x_error_message   out varchar2,
        x_return_status   out varchar2
    ) is
        l_error exception;
        l_annual_election number;
    begin
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_UPDATE_HRAFSA_PLAN ', 'P_BEN_PLAN_ID' || p_ben_plan_id);
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_UPDATE_HRAFSA_PLAN ', 'P_PAY_CYCLE' || p_pay_cycle);
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_UPDATE_HRAFSA_PLAN ', 'P_PAY_DATE' || p_pay_date);
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_UPDATE_HRAFSA_PLAN ', 'P_COV_TIER_NAME' || p_cov_tier_name);
        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_UPDATE_HRAFSA_PLAN ', 'P_ANNUAL_ELECTION' || p_annual_election);
        for x in (
            select
                er.minimum_election,
                case
                    when er.plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                        nvl(er.maximum_election,
                            pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT',
                                                       er.plan_type,
                                                       nvl(er.plan_start_date, sysdate)) * 12)
                    else
                        nvl(er.maximum_election, 0)
                end maximum_election,
                er.plan_start_date,
                er.plan_end_date,
                ee.plan_type,
                er.product_type,
                ee.status,
                ee.ben_plan_id_main,
                er.entrp_id
            from
                ben_plan_enrollment_setup ee,
                ben_plan_enrollment_setup er
            where
                    ee.ben_plan_id = p_ben_plan_id
                and ee.ben_plan_id_main = er.ben_plan_id
        ) loop
            if x.plan_start_date > to_date ( p_effective_date, 'MM/DD/YYYY' ) then
                x_error_message := 'Enter Effective date after the Plan Year Start or Same Date as Plan Year Start for plan type ' || x.plan_type
                ;
                raise l_error;
            end if;

            if x.plan_end_date < to_date ( p_effective_date, 'MM/DD/YYYY' ) then
                x_error_message := 'Enter Effective date before the Plan Year End for plan type ' || x.plan_type;
                raise l_error;
            end if;

            if x.product_type = 'FSA'  --AND X.PLAN_TYPE  IN ('FSA','DCA','LPF','IIR')

             then
                if p_annual_election < x.minimum_election then
                    x_error_message := 'Enter Annual Election more than the Minimum Election for plan type ' || x.plan_type;
                    raise l_error;
                end if;

                if p_annual_election > x.maximum_election then
                    x_error_message := 'Enter Annual Election less than the Maximum Election for plan type ' || x.plan_type;
                    raise l_error;
                end if;

            end if;

            if x.status <> 'P' then
                x_error_message := 'Pending plans can only be changed ';
                raise l_error;
            else
                pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_UPDATE_HRAFSA_PLAN ', ' x.status ' || x.status);
                pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_UPDATE_HRAFSA_PLAN ', ' P_BEN_PLAN_ID ' || p_ben_plan_id);
                update ben_plan_enrollment_setup
                set
                    effective_date = to_date(p_effective_date, 'MM/DD/YYYY'),
                    annual_election = p_annual_election,
                    life_event_code = nvl(p_event_code, life_event_code),
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                    ben_plan_id = p_ben_plan_id
                returning annual_election into l_annual_election;

                pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_UPDATE_HRAFSA_PLAN ', 'l_annual_election ' || l_annual_election);
                if x.product_type = 'FSA' then
                    update pay_details
                    set
                        pay_contrb = nvl(p_pay_contrib,
                                         pc_benefit_plans.calculate_pay_period(x.plan_type,
                                                                               x.entrp_id,
                                                                               p_annual_election,
                                                                               nvl(p_pay_cycle, pay_cycle),
                                                                               p_effective_date,
                                                                               to_char(x.plan_end_date, 'MM/DD/YYYY'))),
                        pay_cycle = p_pay_cycle,
                        first_payroll_date = p_pay_date,
                        effective_date = to_date(p_effective_date, 'MM/DD/YYYY'),
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                        ben_plan_id = p_ben_plan_id;

                end if;

                if p_cov_tier_name is not null then
                    for xx in (
                        select
                            coverage_type
                        from
                            ben_plan_coverages
                        where
                                ben_plan_id = x.ben_plan_id_main
                            and coverage_tier_name = p_cov_tier_name
                    ) loop
                        update ben_plan_coverages
                        set
                            coverage_tier_name = p_cov_tier_name,
                            coverage_type = xx.coverage_type,
                            annual_election = p_annual_election
                        where
                            ben_plan_id = p_ben_plan_id;

                    end loop;
                end if;

            end if;

        end loop;

        pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_UPDATE_HRAFSA_PLAN ', 'AFTER ALL ' || p_ben_plan_id);
    exception
        when l_error then
            x_return_status := 'E';
            pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_UPDATE_HRAFSA_PLAN ', 'x_error_message ' || x_error_message);
        when others then
            x_return_status := 'E';
            pc_log.log_error('PC_ONLINE_ENROLL_DML.PC_UPDATE_HRAFSA_PLAN ', 'sqlerrm ' || sqlerrm);
    end pc_update_hrafsa_plan;

    procedure pc_delete_hrafsa_plan (
        p_ben_plan_id   in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        l_error exception;
    begin
        pc_log.log_error('PC_DELETE_HRAFSA_PLAN', 'P_BEN_PLAN_ID' || p_ben_plan_id);
        for x in (
            select
                plan_type,
                status,
                batch_number
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id = p_ben_plan_id
        ) loop
            if x.status <> 'P' then
                x_error_message := 'Pending plans can only be changed ';
                raise l_error;
            else
                delete from ben_plan_enrollment_setup
                where
                    ben_plan_id = p_ben_plan_id;

                delete from pay_details
                where
                    ben_plan_id = p_ben_plan_id;

                delete from ben_plan_coverages
                where
                    ben_plan_id = p_ben_plan_id;

            end if;
        end loop;

    exception
        when l_error then
            x_return_status := 'E';
    end pc_delete_hrafsa_plan;

    function get_notification (
        p_batch_number in number,
        p_event_name   in varchar2,
        p_acc_id       in number,
        p_user_id      in number
    ) return notify_t
        pipelined
        deterministic
    is
        l_record    notify_row_t;
        l_exist_flg varchar2(1) := 'N';--Added by Karthe on 11th Aug 2015

    begin
        pc_log.log_error('get_notification', 'p_acc_id ' || p_acc_id);
        pc_log.log_error('get_notification', 'p_batch_number ' || p_batch_number);
        pc_log.log_error('get_notification', 'p_event_name ' || p_event_name);
        l_record := null;
         -- All Qualifying event changes
        if p_event_name in ( 'ONLINE_EE_QE_APPROVED', 'ONLINE_EE_QE_DENIED', 'ONLINE_EE_QUALIFY_EVENT_ELECTION_CR' ) then
            for x in (
                select
                    a.pers_id,
                    b.ben_plan_id,
                    b.plan_type,
                    b.acc_id,
                    a.status,
                    b.ben_plan_name
                from
                    ben_life_event_history    a,
                    ben_plan_enrollment_setup b
                where
                        a.batch_number = p_batch_number
                    and a.status = case
                        when p_event_name = 'ONLINE_EE_QE_APPROVED'               then
                            'A'
                        when p_event_name = 'ONLINE_EE_QE_DENIED'                 then
                            'R'
                        when p_event_name = 'ONLINE_EE_QUALIFY_EVENT_ELECTION_CR' then
                            'P'
                                   end
                    and a.acc_id = p_acc_id
                    and b.ben_plan_id = a.ben_plan_id
                    and a.acc_id = b.acc_id
                union
                select
                    a.pers_id,
                    b.ben_plan_id,
                    b.plan_type,
                    b.acc_id,
                    a.status,
                    b.ben_plan_name
                from
                    ben_life_event_history    a,
                    ben_plan_enrollment_setup b
                where
                        a.batch_number = p_batch_number
                    and a.acc_id = p_acc_id
                    and a.status = case
                        when p_event_name = 'ONLINE_EE_QE_APPROVED'               then
                            'A'
                        when p_event_name = 'ONLINE_EE_QE_DENIED'                 then
                            'R'
                        when p_event_name = 'ONLINE_EE_QUALIFY_EVENT_ELECTION_CR' then
                            'P'
                                   end
                    and a.ben_plan_id is null
                    and a.acc_id = b.acc_id
            ) loop
                l_record.person_name := pc_person.get_person_name(x.pers_id);
                l_record.plan_types :=
                    case
                        when l_record.plan_types is null then
                            x.ben_plan_name
                        else l_record.plan_types
                             || ','
                             || x.ben_plan_name
                    end;

                l_record.pers_id := x.pers_id;
                l_record.acc_id := x.acc_id;
                l_record.email := pc_users.get_email(null, x.acc_id, x.pers_id);

                l_record.status := x.status;
            end loop;
        end if;
         -- All new plan approvals, rejections
        if p_event_name in ( 'ONLINE_EE_NEW_PLAN_APPROVED', 'ONLINE_EE_NEW_PLAN_DENIED' ) then
            for x in (
                select
                    a.name,
                    b.ben_plan_id,
                    b.plan_type,
                    b.acc_id,
                    a.status,
                    b.ben_plan_name
                from
                    ben_plan_approvals        a,
                    ben_plan_enrollment_setup b
                where
                        a.batch_number = p_batch_number
                    and a.status = case
                        when p_event_name = 'ONLINE_EE_NEW_PLAN_APPROVED' then
                            'A'
                        when p_event_name = 'ONLINE_EE_NEW_PLAN_DENIED'   then
                            'R'
                                   end
                    and b.acc_id = p_acc_id
                    and b.ben_plan_id = a.ben_plan_id
            ) loop
                l_record.person_name := x.name;
                l_record.plan_types :=
                    case
                        when l_record.plan_types is null then
                            x.ben_plan_name
                        else l_record.plan_types
                             || ','
                             || x.ben_plan_name
                    end;

                l_record.acc_id := x.acc_id;
                l_record.email := pc_users.get_email(null, x.acc_id, null);
                l_record.status := x.status;
                pc_log.log_error('get_notification', 'x.name ' || x.name);
            end loop;
        end if;

        pc_log.log_error('get_notification', 'l_record.email  ' || l_record.email);

         -- ben_plan creation
        if p_event_name = 'ONLINE_EE_ANNUAL_ELECTION' then
            for x in (
                select
                    a.pers_id,
                    b.ben_plan_id,
                    b.plan_type,
                    b.acc_id,
                    a.acc_num,
                    b.ben_plan_name
                from
                    ben_plan_enrollment_setup b,
                    account                   a
                where
                        b.batch_number = p_batch_number
                    and b.status = 'P'
                    and a.acc_id = p_acc_id
                    and a.acc_id = b.acc_id
            ) loop
                l_record.person_name := pc_person.get_person_name(x.pers_id);
                l_record.pers_id := x.pers_id;
                l_record.plan_types :=
                    case
                        when l_record.plan_types is null then
                            x.ben_plan_name
                        else l_record.plan_types
                             || ','
                             || x.ben_plan_name
                    end;

                l_record.acc_id := x.acc_id;
                l_record.email := pc_users.get_email(x.acc_num, x.acc_id, x.pers_id);

            end loop;
        end if;
       -- ben_plan creation
        if p_event_name = 'ONLINE_EE_ANNUAL_ELECTION_WITHDRAWAL' then
            for x in (
                select
                    a.pers_id,
                    a.acc_id,
                    a.acc_num
                from
                    account a
                where
                    a.acc_id = p_acc_id
            ) loop
                l_record.person_name := pc_person.get_person_name(x.pers_id);
                l_record.pers_id := x.pers_id;
                l_record.acc_id := x.acc_id;
                l_record.email := pc_users.get_email(x.acc_num, x.acc_id, x.pers_id);

            end loop;
        end if;

        for x in (
            select
                template_subject,
                template_body
            from
                notification_template
            where
                    event = p_event_name
                and status = 'A'
        ) loop
            l_record.subject := x.template_subject;
            l_record.email_body := replace(
                replace(x.template_body, '<<EMPLOYEE_NAME>>', l_record.person_name),
                '<<PLAN_TYPE>>',
                l_record.plan_types
            );

        end loop;
         --Added by Karthe on 11th Aug 2015
        for x in (
            select
                'Y' email_exist
            from
                email_notifications
            where
                    batch_num = p_batch_number
                and event = p_event_name
        ) loop
            l_exist_flg := x.email_exist;
        end loop;

        if nvl(l_exist_flg, 'N') = 'N' then
            for x in (
                select
                    c.user_id
                from
                    person       a,
                    account      b,
                    online_users c
                where
                        a.pers_id = b.pers_id
                    and b.acc_id = p_acc_id
                    and replace(a.ssn, '-') = c.tax_id
                    and c.user_status = 'A'
            )--Added by Karthe on 11th Aug 2015
             loop
             --Commenetd by Karthe on 11th Aug 2015 for the Duplicate Notifications in the message center issue
             /*pc_notifications.insert_web_notification('benefits@sterlingadministration.com'
                                                 ,   l_record.email
                                                 ,   l_record.subject
                                                 ,   l_record.email_body
                                                 ,   X.user_id
                                                 ,   p_acc_id);*/

                pc_notifications.insert_web_notification('benefits@sterlingadministration.com', l_record.email, l_record.subject, l_record.email_body
                , x.user_id,
                                                         p_acc_id, p_event_name, p_batch_number);
            end loop;
         --PIPE ROW(l_record);
        end if;

        pipe row ( l_record );
    end get_notification;

-- Added by Joshi for Webform Enrollment.
    procedure process_webform_enroll (
        p_enroll_source          in varchar2,
        p_ssn                    in varchar2,
        p_first_name             in varchar2,
        p_last_name              in varchar2,
        p_middle_name            in varchar2,
        p_title                  in varchar2,
        p_gender                 in varchar2,
        p_birth_date             in varchar2,
        p_id_type                in varchar2,
        p_id_number              in varchar2,
        p_address                in varchar2,
        p_city                   in varchar2,
        p_state                  in varchar2,
        p_zip                    in varchar2,
        p_phone                  in varchar2,
        p_email                  in varchar2,
        p_carrier_id             in number,
        p_health_plan_eff_date   in varchar2,
        p_entrp_id               in varchar2,
        p_account_type           in varchar2_tbl,
        p_transaction_id         in number,
        p_verification_date      in varchar2,
        p_id_verification_status in varchar,
        p_user_id                in number,
        p_plan_type_var          in varchar2,
        p_deductible_var         in varchar2,
        p_lang_pref              in varchar2,
        p_ip_address             in varchar2,
        p_ben_plan_id            in varchar2_tbl,
        p_plan_type              in varchar2_tbl,
        p_coverage_type          in varchar2_tbl,
        p_effective_date         in varchar2_tbl,
        p_annual_election        in varchar2_tbl,
        p_pay_contrib            in varchar2_tbl,
        p_pay_cycle              in varchar2_tbl,
        p_pay_date               in varchar2_tbl,
        p_cov_tier_name          in varchar2_tbl,
        p_deductible             in varchar2_tbl,
        p_event_code             in varchar2_tbl,
        p_dep_ssn                in varchar2_tbl,
        p_debit_card             in varchar2_tbl,
        p_person_type            in varchar2_tbl,
        p_dep_first_name         in varchar2_tbl,
        p_dep_middle_name        in varchar2_tbl,
        p_dep_last_name          in varchar2_tbl,
        p_dep_gender             in varchar2_tbl,
        p_dep_birth_date         in varchar2_tbl,
        p_dep_relative           in varchar2_tbl,
        p_dep_card_ssn           in varchar2_tbl,
        p_batch_number           in out number,
        x_error_message          out varchar2,
        x_return_status          out varchar2
    ) is

        l_batch_number  number;
        l_debit_card    varchar2_tbl;
        l_account_type  varchar2_tbl;
        l_dep_debitcard varchar2_tbl;
        l_dependent_ssn varchar2_tbl;
        l_person_type   varchar2_tbl;
        l_dep_ssn       varchar2_tbl;
        j               integer := 0;
    begin
        select
            batch_num_seq.nextval
        into l_batch_number
        from
            dual;

        p_batch_number := l_batch_number;

-- call Proc to insert demographic information
        pc_online_enroll_dml.pc_insert_demographics(
            p_enroll_source        => p_enroll_source,
            p_first_name           => p_first_name,
            p_last_name            => p_last_name,
            p_middle_name          => p_middle_name,
            p_title                => p_title,
            p_gender               => p_gender,
            p_birth_date           => p_birth_date,
            p_ssn                  => p_ssn,
            p_id_type              => p_id_type,
            p_id_number            => p_id_number,
            p_address              => p_address,
            p_city                 => p_city,
            p_state                => p_state,
            p_zip                  => p_zip,
            p_phone                => p_phone,
            p_email                => p_email,
            p_carrier_id           => p_carrier_id,
            p_health_plan_eff_date => p_health_plan_eff_date,
            p_entrp_id             => p_entrp_id,
            p_account_type         => p_account_type,
            p_user_id              => p_user_id,
            p_plan_type            => p_plan_type_var,
            p_deductible           => p_deductible_var,
            p_lang_pref            => p_lang_pref,
            p_ip_address           => p_ip_address,
            p_batch_number         => l_batch_number,
            x_error_message        => x_error_message,
            x_return_status        => x_return_status
        );

        pc_log.log_error('process_webform_enrol PC_INSERT_DEMOGRAPHICS ||  ', 'p_entrp_id  ' || p_entrp_id);
        pc_log.log_error('process_webform_enrol PC_INSERT_DEMOGRAPHICS || l', 'X_RETURN_STATUS  ' || x_return_status);
        if x_return_status = 'S' then
            pc_online_enroll_dml.pc_insert_hrafsa_plan(
                p_batch_number    => l_batch_number,
                p_ssn             => p_ssn,
                p_ben_plan_id     => p_ben_plan_id,
                p_plan_type       => p_plan_type,
                p_effective_date  => p_effective_date,
                p_annual_election => p_annual_election,
                p_pay_contrib     => p_pay_contrib,
                p_pay_cycle       => p_pay_cycle,
                p_pay_date        => p_pay_date,
                p_cov_tier_name   => p_cov_tier_name,
                p_deductible      => p_deductible,
                p_event_code      => p_event_code,
                x_error_message   => x_error_message,
                x_return_status   => x_return_status
            );
        end if;

        pc_log.log_error('process_webform_enrol PC_INSERT_HRAFSA_PLAN || l', 'X_RETURN_STATUS  ' || x_return_status);
        if
            x_return_status = 'S'
            and p_coverage_type.count > 0
        then
            pc_online_enroll_dml.pc_insert_coverage(
                p_batch_number  => l_batch_number,
                p_ssn           => p_ssn,
                p_ben_plan_id   => p_ben_plan_id,
                p_coverage_type => p_coverage_type
            );
        end if;

        pc_log.log_error('process_webform_enrol pc_insert_coverage || l', 'X_RETURN_STATUS  ' || x_return_status);
        pc_log.log_error('process_webform_enroll', 'p_entrp_id  ' || p_entrp_id);

-- Added by Joshi for 5026. need to process depedents.
        if x_return_status = 'S' then
            pc_online_enroll_dml.pc_insert_dependent(
                p_batch_number    => l_batch_number,
                p_ssn             => p_ssn,
                p_dep_first_name  => p_dep_first_name,
                p_dep_middle_name => p_dep_middle_name,
                p_dep_last_name   => p_dep_last_name,
                p_dep_gender      => p_dep_gender,
                p_dep_birth_date  => p_dep_birth_date,
                p_dep_ssn         => p_dep_ssn,
                p_dep_relative    => p_dep_relative,
                p_account_type    => p_account_type,
                p_user_id         => p_user_id,
                x_error_message   => x_error_message,
                x_return_status   => x_return_status
            );
        end if;
--pc_log.log_error('process_webform_enroll after PC_INSERT_DEPENDENT','X_RETURN_STATUS  '||X_RETURN_STATUS );

-- This is added incase dependent exist with same SSN.
        if x_error_message is not null then
            x_return_status := 'E';
        end if;
        if p_person_type.count > 0 then
            l_debit_card := array_fill(p_debit_card, p_person_type.count);
            l_dep_debitcard := array_fill(p_debit_card, p_person_type.count);
            l_person_type := array_fill(p_person_type, p_person_type.count);
            l_account_type := array_fill(p_debit_card, p_person_type.count);
            l_dep_ssn := array_fill(p_dep_card_ssn, p_dep_card_ssn.count);

  --pc_log.log_error('process_webform_enroll','P_DEBIT_CARD  '||P_DEBIT_CARD(1) );

            if l_person_type(1) = 'SUBSCRIBER' then
                l_dependent_ssn(1) := null;
                l_account_type(1) := l_debit_card(1);
                j := 1;
            end if;

            if l_debit_card(1) is null then
                select
                    account_type
                into
                    l_debit_card
                (1)
                from
                    online_enrollment
                where
                    batch_number = p_batch_number;

            end if;

            for i in 1..l_dep_ssn.count loop
                l_dependent_ssn(j + i) := l_dep_ssn(i);
                l_account_type(j + i) := l_debit_card(1);
                l_debit_card(j + i) := l_debit_card(1);
        --pc_log.log_error('process_webform_enroll','l_Dependent_ssn  '||l_Dependent_ssn(i) );
        --pc_log.log_error('process_webform_enroll','l_debit_card  '||l_debit_card(i) );
        --pc_log.log_error('process_webform_enroll','l_account_type  '||l_account_type(i) );
            end loop;

            if x_return_status = 'S' then
                pc_online_enroll_dml.update_debit_card(
                    p_batch_number => l_batch_number,
                    p_ssn          => p_ssn,
                    p_dep_ssn      => l_dependent_ssn,
                    p_account_type => l_account_type
      --,P_DEBIT_CARD    => P_DEBIT_CARD
                    ,
                    p_debit_card   => l_debit_card  -- added by Joshi for 5026.
                    ,
                    p_person_type  => p_person_type
                );
            end if;

            pc_log.log_error('process_webform_enroll after UPDATE_DEBIT_CARD', 'X_RETURN_STATUS  ' || x_return_status);
        end if;

        if x_return_status = 'S' then
            pc_online_enroll_dml.process_enrollment(
                p_batch_number           => l_batch_number,
                p_enroll_source          => p_enroll_source,
                p_entrp_id               => p_entrp_id,
                p_account_type           => p_account_type,
                p_id_verification_status => p_id_verification_status,
                p_transaction_id         => p_transaction_id,
                p_verification_date      => p_verification_date,
                p_user_id                => p_user_id,
                x_error_message          => x_error_message,
                x_return_status          => x_return_status
            );
        end if;

        pc_log.log_error('process_webform_enroll', 'x_return_status  ' || x_return_status);
/*
IF X_RETURN_STATUS  = 'S' THEN
   PC_NOTIFICATIONS.WEBFORM_ER_NOTFICATION
   (P_BATCH_NUM => l_batch_number);
END IF ;
*/
    end process_webform_enroll;

end pc_online_enroll_dml;
/

