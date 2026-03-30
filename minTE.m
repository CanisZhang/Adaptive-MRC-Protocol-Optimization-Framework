function TE = minTE(PGSE_delta, OGSEHz1, OGSEHz2)

    timeACQ = 27;% 注意调整
    OGSEdelta = max(1000/OGSEHz1, 1000/OGSEHz2);
    TE = max(2*ceil(OGSEdelta+timeACQ), PGSE_delta+48);% 注意调整
end
