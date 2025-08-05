-- liquibase formatted sql
-- changeset SAMQA:1754373928058 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\google_geocode.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/google_geocode.sql:null:a25627658afe481afc10b82be16af85f80751260:create

create or replace function samqa.google_geocode (
    p_address varchar2
) return sdo_geometry is
    l_http_req  utl_http.req;
    l_http_resp utl_http.resp;
    l_response  long;
    l_latlon    long;
begin
    l_http_req := utl_http.begin_request(url => 'http://maps.google.com/maps/geo'
                                                || '?q='
                                                || utl_url.escape(p_address)
                                                || -- address to geocode
                                                 '=csv'
                                                ||                        -- simplest return type
                                                 '=abcdef');                        -- Google API site key

    l_http_resp := utl_http.get_response(l_http_req);
    utl_http.read_text(l_http_resp, l_response);
    utl_http.end_response(l_http_resp);
    l_latlon := substr(l_response,
                       instr(l_response, ',', 1, 2) + 1);

    return sdo_geometry(2001,
                        8307,
                        sdo_point_type(to_number(substr(l_latlon,
                                                        instr(l_latlon, ',') + 1)),
                                       to_number(substr(l_latlon,
                                                        1,
                                                        instr(l_latlon, ',') - 1)),
                                       null),
                        null,
                        null);

end google_geocode;
/

