create or replace force editionable view samqa.claim_provider_edi_vw (
    seg,
    s03,
    rn,
    next_rn,
    billing_provider_name,
    billing_provider_address1,
    billing_provider_address2,
    billing_provider_city,
    billing_provider_state,
    billing_provider_zip,
    billing_provider_country,
    billing_provider_acct_number,
    billing_provider_contact_name,
    billing_provider_email,
    billing_provider_phone
) as
    select
        seg,
        s03,
        rn,
        nvl(lead(rn)
            over(partition by seg
                 order by
                     rn
        ),
            (
            select
                count(*)
            from
                claim_edi_external k
        )) next_rn,
        billing_provider_name,
        billing_provider_address1,
        billing_provider_address2,
        billing_provider_city,
        billing_provider_state,
        billing_provider_zip,
        billing_provider_country,
        billing_provider_acct_number,
        billing_provider_contact_name,
        billing_provider_email,
        billing_provider_phone
    from
        (
            with provider as (
                select
                    rownum,
                    rn,
                    seg,
                    s01,
                    s03,
                    s04,
                    s02,
                    s05,
                    s06,
                    s07,
                    s08,
                    s09,
                    s10,
                    s11,
                    s12,
                    s13,
                    s14,
                    s15,
                    s16,
                    s17,
                    s18,
                    lead(rn, 1, 0)
                    over(
                        order by
                            rn
                    ) - 1 as rn_prev
                from
                    (
                        select
                            rownum rn,
                            seg,
                            s01,
                            s03,
                            s04,
                            s02,
                            s05,
                            s06,
                            s07,
                            s08,
                            s09,
                            s10,
                            s11,
                            s12,
                            s13,
                            s14,
                            s15,
                            s16,
                            s17,
                            s18
                        from
                            claim_edi_external
                    ) x
                where
                        seg = 'HL'
                    and s03 = '20'
            )
            select
                b.seg,
                b.s03,
                b.rn,
                max(
                    case
                        when x.seg = 'NM1'
                             and x.s01 = '85'
                             and b.s03 = '20' then
                            x.s03
                        else
                            ' '
                    end
                ) billing_provider_name,
                max(
                    case
                        when x.seg = 'N3'
                             and b.s03 = '20' then
                            x.s01
                        else
                            ' '
                    end
                ) billing_provider_address1,
                max(
                    case
                        when x.seg = 'N3'
                             and b.s03 = '20' then
                            x.s02
                        else
                            ' '
                    end
                ) billing_provider_address2,
                max(
                    case
                        when x.seg = 'N4'
                             and b.s03 = '20' then
                            x.s01
                        else
                            ' '
                    end
                ) billing_provider_city,
                max(
                    case
                        when x.seg = 'N4'
                             and b.s03 = '20' then
                            x.s02
                        else
                            ' '
                    end
                ) billing_provider_state,
                max(
                    case
                        when x.seg = 'N4'
                             and b.s03 = '20' then
                            x.s03
                        else
                            ' '
                    end
                ) billing_provider_zip,
                max(
                    case
                        when x.seg = 'N4'
                             and b.s03 = '20' then
                            x.s04
                        else
                            ' '
                    end
                ) billing_provider_country,
                max(
                    case
                        when x.seg = 'NM1'
                             and x.s08 = '24'
                             and b.s03 = '20' then                             -- GN modified
                            x.s09
                        else
                            ' '
                    end
                ) billing_provider_acct_number,
                max(
                    case
                        when x.seg = 'PER' then
                            x.s02
                        else
                            ' '
                    end
                ) billing_provider_contact_name         -- GN CREATED
                ,
                max(
                    case
                        when x.seg = 'PER'
                             and x.s03 = 'EM' then
                            x.s04
                        else
                            ' '
                    end
                ) billing_provider_email                -- GN CREATED
                ,
                max(
                    case
                        when x.seg = 'PER'
                             and x.s03 = 'TE' then
                            x.s04
                        else
                            ' '
                    end
                ) billing_provider_phone                -- GN CREATED
            from
                (
                    select
                        rownum rn,
                        x.*
                    from
                        claim_edi_external x
                )        x,
                provider b
            where
                        x.rn <= b.rn + 6
                    and x.rn >= b.rn
                and b.seg = 'HL'
            group by
                b.seg,
                b.s03,
                b.rn
            order by
                b.rn
        );


-- sqlcl_snapshot {"hash":"2acba4ec3f031d1639017fae8bdd0beb920d39ca","type":"VIEW","name":"CLAIM_PROVIDER_EDI_VW","schemaName":"SAMQA","sxml":""}