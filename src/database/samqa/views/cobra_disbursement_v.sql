create or replace force editionable view samqa.cobra_disbursement_v (
    clientname,
    ord,
    clientid,
    qb_last_name,
    qb_first_name,
    planname,
    premium,
    divisionname,
    memberid,
    clientdivisionid,
    premiumduedate,
    remit,
    policy_number,
    firstname,
    lastname,
    phone,
    address1,
    address2,
    city,
    state,
    postalcode,
    active,
    carriername
) as
    select distinct
        c.clientname,
        'DIVISION-CURRENT'                                                   ord,
        c.clientid,
        '"'
        || qb.lastname
        || '"'                                                               qb_last_name,
        '"'
        || qb.firstname
        || '"'                                                               qb_first_name,
        '"'
        || a.planname
        || '"'                                                               planname,
        round(a.premiumamount - a.employeesubsidy, 2)                        premium,
        cd.divisionname,
        qb.memberid,
        cd.clientdivisionid,
        trunc(a.premiumduedate)                                              premiumduedate,
        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
        v.carrierplanidentification                                          policy_number,
        '"'
        || c.clientname
        || '"'                                                               firstname,
        '"'
        || ''
        || '"'                                                               lastname,
        '"'
        || c.phone
        || '"'                                                               phone,
        '"'
        || c.address1
        || '"'                                                               address1,
        '"'
        || c.address2
        || '"'                                                               address2,
        '"'
        || c.city
        || '"'                                                               city,
        '"'
        || c.state
        || '"'                                                               state,
        '"'
        || c.postalcode
        || '"'                                                               postalcode,
        '"'
        || '1'
        || '"'                                                               active,
        '"'
        || c.clientname
        || '"'                                                               carriername
    from
        qbpayment            a,
        qbplan               b,
        clientplanqb         v,
        client               c,
        clientdivision       cd,
        clientdivisionqbplan cdq,
        carrier              cr,
        qb
    where
            a.planname = b.planname
        and a.memberid = b.memberid
        and qb.clientdivisionid = cd.clientdivisionid
        and b.clientplanqbid = v.clientplanqbid
        and cdq.clientdivisionid = cd.clientdivisionid
        and cdq.clientplanqbid = v.clientplanqbid
        and cdq.clientplanqbid = b.clientplanqbid
  --AND B.ISELECTED = 1
        and cr.carrierid = v.carrierid
        and c.clientid = cd.clientid
        and trunc(a.depositdate) < '06-SEP-2016'
        and trunc(a.premiumduedate) between '01-AUG-2016' and '30-AUG-2016'
        and v.clientid = c.clientid
        and qb.memberid = a.memberid
        and v.iscarrierremit = 0
    union
    select distinct
        c.clientname,
        'DIVISION-PAST'                                                      ord,
        c.clientid,
        '"'
        || qb.lastname
        || '"'                                                               qb_last_name,
        '"'
        || qb.firstname
        || '"'                                                               qb_first_name,
        '"'
        || a.planname
        || '"'                                                               planname,
        round(a.premiumamount - a.employeesubsidy, 2)                        premium,
        cd.divisionname,
        qb.memberid,
        cd.clientdivisionid,
        trunc(a.premiumduedate)                                              premiumduedate,
        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
        v.carrierplanidentification                                          policy_number,
        '"'
        || c.clientname
        || '"'                                                               firstname,
        '"'
        || ''
        || '"'                                                               lastname,
        '"'
        || c.phone
        || '"'                                                               phone,
        '"'
        || c.address1
        || '"'                                                               address1,
        '"'
        || c.address2
        || '"'                                                               address2,
        '"'
        || c.city
        || '"'                                                               city,
        '"'
        || c.state
        || '"'                                                               state,
        '"'
        || c.postalcode
        || '"'                                                               postalcode,
        '"'
        || '1'
        || '"'                                                               active,
        '"'
        || c.clientname
        || '"'                                                               carriername
    from
        qbpayment            a,
        qbplan               b,
        clientplanqb         v,
        client               c,
        clientdivision       cd,
        clientdivisionqbplan cdq,
        carrier              cr,
        qb
    where
            a.planname = b.planname
        and a.memberid = b.memberid
        and qb.clientdivisionid = cd.clientdivisionid
        and b.clientplanqbid = v.clientplanqbid
        and cdq.clientdivisionid = cd.clientdivisionid
        and cdq.clientplanqbid = v.clientplanqbid
        and cdq.clientplanqbid = b.clientplanqbid
  --AND B.ISELECTED = 1
        and cr.carrierid = v.carrierid
        and c.clientid = cd.clientid
        and trunc(a.depositdate) between '06-AUG-2016' and '06-SEP-2016'
        and trunc(a.premiumduedate) < '01-AUG-2016'
        and v.clientid = c.clientid
        and qb.memberid = a.memberid
        and v.iscarrierremit = 0
    union -- no division
    select distinct
        c.clientname,
        'NODIVISION-CURRENT'                                                 ord,
        c.clientid,
        '"'
        || qb.lastname
        || '"'                                                               qb_last_name,
        '"'
        || qb.firstname
        || '"'                                                               qb_first_name,
        '"'
        || a.planname
        || '"'                                                               planname,
        round(a.premiumamount - a.employeesubsidy, 2)                        premium,
        null,
        qb.memberid,
        null,
        trunc(a.premiumduedate)                                              premiumduedate,
        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
        v.carrierplanidentification                                          policy_number,
        '"'
        || c.clientname
        || '"'                                                               firstname,
        '"'
        || ''
        || '"'                                                               lastname,
        '"'
        || c.phone
        || '"'                                                               phone,
        '"'
        || c.address1
        || '"'                                                               address1,
        '"'
        || c.address2
        || '"'                                                               address2,
        '"'
        || c.city
        || '"'                                                               city,
        '"'
        || c.state
        || '"'                                                               state,
        '"'
        || c.postalcode
        || '"'                                                               postalcode,
        '"'
        || '1'
        || '"'                                                               active,
        '"'
        || c.clientname
        || '"'                                                               carriername
    from
        qbpayment    a,
        qbplan       b,
        clientplanqb v,
        client       c,
        carrier      cr,
        qb
    where
            a.planname = b.planname
        and a.memberid = b.memberid
        and b.clientplanqbid = v.clientplanqbid
  --AND B.ISELECTED = 1
        and cr.carrierid = v.carrierid
        and trunc(a.depositdate) <= '06-SEP-2016'
        and trunc(a.premiumduedate) between '01-AUG-2016' and '30-AUG-2016'
        and v.clientid = c.clientid
        and qb.memberid = a.memberid
        and v.iscarrierremit = 0
        and not exists (
            select
                *
            from
                clientdivision       cd,
                clientdivisionqbplan cdq
            where
                    qb.clientdivisionid = cd.clientdivisionid
                and c.clientid = cd.clientid
                and cdq.clientdivisionid = cd.clientdivisionid
                and cdq.clientplanqbid = v.clientplanqbid
                and cdq.clientplanqbid = b.clientplanqbid
        )
    union -- no division
    select distinct
        c.clientname,
        'NODIVISION-PAST'                                                    ord,
        c.clientid,
        '"'
        || qb.lastname
        || '"'                                                               qb_last_name,
        '"'
        || qb.firstname
        || '"'                                                               qb_first_name,
        '"'
        || a.planname
        || '"'                                                               planname,
        round(a.premiumamount - a.employeesubsidy, 2)                        premium,
        null,
        qb.memberid,
        null,
        trunc(a.premiumduedate)                                              premiumduedate,
        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
        v.carrierplanidentification                                          policy_number,
        '"'
        || c.clientname
        || '"'                                                               firstname,
        '"'
        || ''
        || '"'                                                               lastname,
        '"'
        || c.phone
        || '"'                                                               phone,
        '"'
        || c.address1
        || '"'                                                               address1,
        '"'
        || c.address2
        || '"'                                                               address2,
        '"'
        || c.city
        || '"'                                                               city,
        '"'
        || c.state
        || '"'                                                               state,
        '"'
        || c.postalcode
        || '"'                                                               postalcode,
        '"'
        || '1'
        || '"'                                                               active,
        '"'
        || c.clientname
        || '"'                                                               carriername
    from
        qbpayment    a,
        qbplan       b,
        clientplanqb v,
        client       c,
        carrier      cr,
        qb
    where
            a.planname = b.planname
        and a.memberid = b.memberid
        and b.clientplanqbid = v.clientplanqbid
  --AND B.ISELECTED = 1
        and cr.carrierid = v.carrierid
        and trunc(a.depositdate) between '06-AUG-2016' and '06-SEP-2016'
        and trunc(a.premiumduedate) < '01-AUG-2016'
        and v.clientid = c.clientid
        and qb.memberid = a.memberid
        and v.iscarrierremit = 0
        and not exists (
            select
                *
            from
                clientdivision       cd,
                clientdivisionqbplan cdq
            where
                    qb.clientdivisionid = cd.clientdivisionid
                and c.clientid = cd.clientid
                and cdq.clientdivisionid = cd.clientdivisionid
                and cdq.clientplanqbid = v.clientplanqbid
                and cdq.clientplanqbid = b.clientplanqbid
        )
    union -- carrier
    select distinct
        c.clientname,
        'CARRIER-CURRENT'                                                    ord,
        c.clientid,
        '"'
        || qb.lastname
        || '"'                                                               qb_last_name,
        '"'
        || qb.firstname
        || '"'                                                               qb_first_name,
        '"'
        || a.planname
        || '"'                                                               planname,
        round(a.premiumamount - a.employeesubsidy, 2)                        premium,
        null,
        qb.memberid,
        null,
        trunc(a.premiumduedate)                                              premiumduedate,
        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
        v.carrierplanidentification                                          policy_number,
        '"'
        || decode(v.iscarrierremit, 0, c.clientname, cc.firstname)
        || '"'                                                               firstname,
        '"'
        || decode(v.iscarrierremit, 0, '', cc.lastname)
        || '"'                                                               lastname,
        '"'
        || decode(v.iscarrierremit, 0, c.phone, cc.phone)
        || '"'                                                               phone,
        '"'
        || decode(v.iscarrierremit, 0, c.address1, cc.address1)
        || '"'                                                               address1,
        '"'
        || decode(v.iscarrierremit, 0, c.address2, cc.address2)
        || '"'                                                               address2,
        '"'
        || decode(v.iscarrierremit, 0, c.city, cc.city)
        || '"'                                                               city,
        '"'
        || decode(v.iscarrierremit, 0, c.state, cc.state)
        || '"'                                                               state,
        '"'
        || decode(v.iscarrierremit, 0, c.postalcode, cc.postalcode)
        || '"'                                                               postalcode,
        '"'
        || cc.active
        || '"'                                                               active,
        '"'
        || decode(v.iscarrierremit, 0, c.clientname, cr.carriername)
        || '"'                                                               carriername
    from
        qbpayment      a,
        qbplan         b,
        clientplanqb   v,
        client         c,
        carrier        cr,
        qb,
        carriercontact cc
    where
            a.planname = b.planname
        and a.memberid = b.memberid
        and b.clientplanqbid = v.clientplanqbid
 -- AND B.ISELECTED = 1
        and cr.carrierid = v.carrierid
        and v.carrierremittancecontactid = cc.carriercontactid
        and v.iscarrierremit = 1
        and trunc(a.depositdate) < '06-SEP-2016'
        and trunc(a.premiumduedate) between '01-AUG-2016' and '30-AUG-2016'
        and v.clientid = c.clientid
        and qb.memberid = a.memberid
    union -- carrier
    select distinct
        c.clientname,
        'CARRIER-PAST'                                                       ord,
        c.clientid,
        '"'
        || qb.lastname
        || '"'                                                               qb_last_name,
        '"'
        || qb.firstname
        || '"'                                                               qb_first_name,
        '"'
        || a.planname
        || '"'                                                               planname,
        round(a.premiumamount - a.employeesubsidy, 2)                        premium,
        null,
        qb.memberid,
        null,
        trunc(a.premiumduedate)                                              premiumduedate,
        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
        v.carrierplanidentification                                          policy_number,
        '"'
        || decode(v.iscarrierremit, 0, c.clientname, cc.firstname)
        || '"'                                                               firstname,
        '"'
        || decode(v.iscarrierremit, 0, '', cc.lastname)
        || '"'                                                               lastname,
        '"'
        || decode(v.iscarrierremit, 0, c.phone, cc.phone)
        || '"'                                                               phone,
        '"'
        || decode(v.iscarrierremit, 0, c.address1, cc.address1)
        || '"'                                                               address1,
        '"'
        || decode(v.iscarrierremit, 0, c.address2, cc.address2)
        || '"'                                                               address2,
        '"'
        || decode(v.iscarrierremit, 0, c.city, cc.city)
        || '"'                                                               city,
        '"'
        || decode(v.iscarrierremit, 0, c.state, cc.state)
        || '"'                                                               state,
        '"'
        || decode(v.iscarrierremit, 0, c.postalcode, cc.postalcode)
        || '"'                                                               postalcode,
        '"'
        || cc.active
        || '"'                                                               active,
        '"'
        || decode(v.iscarrierremit, 0, c.clientname, cr.carriername)
        || '"'                                                               carriername
    from
        qbpayment      a,
        qbplan         b,
        clientplanqb   v,
        client         c,
        carrier        cr,
        qb,
        carriercontact cc
    where
            a.planname = b.planname
        and a.memberid = b.memberid
        and b.clientplanqbid = v.clientplanqbid
 -- AND B.ISELECTED = 1
        and cr.carrierid = v.carrierid
        and v.carrierremittancecontactid = cc.carriercontactid
        and v.iscarrierremit = 1
        and trunc(a.depositdate) between '06-AUG-2016' and '06-SEP-2016'
        and trunc(a.premiumduedate) < '01-AUG-2016'
        and v.clientid = c.clientid
        and qb.memberid = a.memberid
    union
    select distinct
        c.clientname,
        'SUBSIDY-DIVISION'                                                   ord,
        c.clientid,
        '"'
        || qb.lastname
        || '"'                                                               qb_last_name,
        '"'
        || qb.firstname
        || '"'                                                               qb_first_name,
        '"'
        || b.planname
        || '"'                                                               planname,
        round((case
            when qss.subsidyamounttype = 'FLAT' then
                to_number(cqr.rate) - to_number(regexp_replace(qss.amount, '[^.0-9]+', ''))
            else cqr.rate *(nvl(to_number(replace(cqr.qbpremiumadminfee, '%')),
                                1) / 100)
        end),
              2)                                                             premium,
        cd.divisionname,
        qb.memberid,
        cd.clientdivisionid,
        to_date('01-AUG-2016')                                               premiumduedate,
        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
        v.carrierplanidentification                                          policy_number,
        '"'
        || c.clientname
        || '"'                                                               firstname,
        '"'
        || ''
        || '"'                                                               lastname,
        '"'
        || c.phone
        || '"'                                                               phone,
        '"'
        || c.address1
        || '"'                                                               address1,
        '"'
        || c.address2
        || '"'                                                               address2,
        '"'
        || c.city
        || '"'                                                               city,
        '"'
        || c.state
        || '"'                                                               state,
        '"'
        || c.postalcode
        || '"'                                                               postalcode,
        '"'
        || '1'
        || '"'                                                               active,
        '"'
        || c.clientname
        || '"'                                                               carriername
    from
        qbplan                   b,
        clientplanqb             v,
        client                   c,
        clientdivision           cd,
        clientdivisionqbplan     cdq,
        carrier                  cr,
        qb,
        cobrap.qbsubsidyschedule qss,
        clientplanqbrate         cqr
    where
            qb.clientdivisionid = cd.clientdivisionid
        and b.clientplanqbid = v.clientplanqbid
        and cdq.clientdivisionid = cd.clientdivisionid
        and cdq.clientplanqbid = v.clientplanqbid
        and cdq.clientplanqbid = b.clientplanqbid
        and v.clientid = c.clientid
        and qb.memberid = b.memberid
        and v.iscarrierremit = 0
        and cr.carrierid = v.carrierid
        and c.clientid = cd.clientid
        and '01-AUG-2016' between qss.startdate and nvl(qss.enddate, sysdate)
        and '01-AUG-2016' between b.startdate and nvl(b.enddate, sysdate)
        and qss.insurancetype = b.insurancetype
        and qss.memberid = qb.memberid
        and b.clientplanqbid = cqr.clientplanqbid
        and cqr.qbcoveragelevel = b.coveragelevel
        and b.iselected = 1
        and '01-AUG-2016' between cqr.effectivedate and nvl(cqr.enddate, sysdate)
        and not exists (
            select
                *
            from
                qbpayment a
            where
                    a.memberid = b.memberid
                and trunc(a.depositdate) between '06-AUG-2016' and '06-SEP-2016'
                and trunc(a.premiumduedate) < '01-SEP-2016'
        )
    union
    select distinct
        c.clientname,
        'SUBSIDY-NODIVISION'                                                 ord,
        c.clientid,
        '"'
        || qb.lastname
        || '"'                                                               qb_last_name,
        '"'
        || qb.firstname
        || '"'                                                               qb_first_name,
        '"'
        || b.planname
        || '"'                                                               planname,
        round((case
            when qss.subsidyamounttype = 'FLAT' then
                to_number(cqr.rate) - to_number(regexp_replace(qss.amount, '[^.0-9]+', ''))
            else cqr.rate *(nvl(to_number(replace(cqr.qbpremiumadminfee, '%')),
                                1) / 100)
        end),
              2)                                                             premium,
        null                                                                 divisionname,
        qb.memberid,
        null                                                                 clientdivisionid,
        to_date('01-AUG-2016')                                               premiumduedate,
        decode(v.iscarrierremit, 0, 'REMIT_TO_EMPLOYER', 'REMIT_TO_CARRIER') remit,
        v.carrierplanidentification                                          policy_number,
        '"'
        || c.clientname
        || '"'                                                               firstname,
        '"'
        || ''
        || '"'                                                               lastname,
        '"'
        || c.phone
        || '"'                                                               phone,
        '"'
        || c.address1
        || '"'                                                               address1,
        '"'
        || c.address2
        || '"'                                                               address2,
        '"'
        || c.city
        || '"'                                                               city,
        '"'
        || c.state
        || '"'                                                               state,
        '"'
        || c.postalcode
        || '"'                                                               postalcode,
        '"'
        || '1'
        || '"'                                                               active,
        '"'
        || c.clientname
        || '"'                                                               carriername
    from
        qbplan                   b,
        clientplanqb             v,
        client                   c,
        carrier                  cr,
        qb,
        cobrap.qbsubsidyschedule qss,
        clientplanqbrate         cqr
    where
            b.clientplanqbid = v.clientplanqbid
        and v.clientid = c.clientid
        and qb.memberid = b.memberid
        and v.iscarrierremit = 0
        and cr.carrierid = v.carrierid
        and '01-AUG-2016' between qss.startdate and nvl(qss.enddate, sysdate)
        and '01-AUG-2016' between b.startdate and nvl(b.enddate, sysdate)
        and qss.insurancetype = b.insurancetype
        and qss.memberid = qb.memberid
        and b.clientplanqbid = cqr.clientplanqbid
        and cqr.qbcoveragelevel = b.coveragelevel
        and b.iselected = 1
        and '01-AUG-2016' between cqr.effectivedate and nvl(cqr.enddate, sysdate)
        and not exists (
            select
                *
            from
                qbpayment a
            where
                    a.memberid = b.memberid
                and trunc(a.depositdate) between '06-AUG-2016' and '06-SEP-2016'
                and trunc(a.premiumduedate) < '01-SEP-2016'
        )
        and not exists (
            select
                *
            from
                clientdivision       cd,
                clientdivisionqbplan cdq
            where
                    qb.clientdivisionid = cd.clientdivisionid
                and c.clientid = cd.clientid
                and cdq.clientdivisionid = cd.clientdivisionid
                and cdq.clientplanqbid = v.clientplanqbid
                and cdq.clientplanqbid = b.clientplanqbid
        );


-- sqlcl_snapshot {"hash":"0158e56a9fb35e0e87989ab557cc5bfff47f0fee","type":"VIEW","name":"COBRA_DISBURSEMENT_V","schemaName":"SAMQA","sxml":""}