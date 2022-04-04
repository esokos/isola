function ok = write_qkml1(str1,dp1,rk1,str2,dp2,rk2,tazm,tplng,tlngth,pazm,pplng,plngth,nazm,nplng,nlngth,auth,nclvd,nDC,niso,mmom,nMrr,nMtt,nMpp,nMrt,nMrp,nMtp)


%% initialize values
% str1=num2str(150); dp1=num2str(50); rk1=num2str(-40);
% str2=num2str(150); dp2=num2str(50); rk2=num2str(-40);
% tazm=num2str(150); tplng=num2str(50); tlngth=num2str(1e15);
% pazm=num2str(150); pplng=num2str(50); plngth=num2str(1e15);
% nazm=num2str(150); nplng=num2str(50); nlngth=num2str(1e15);
% auth='UPSL';
% nclvd=num2str(20); nDC=num2str(10); niso=num2str(0);
% mmom=num2str(1e20);
% nMrr=num2str(1e20); nMtt=num2str(1e20); nMpp=num2str(1e20);
% nMrt=num2str(1e20); nMrp=num2str(1e20); nMtp=num2str(1e20);

%%
docNode = com.mathworks.xml.XMLUtils.createDocument('focalMechanism');
momenttensor = docNode.getDocumentElement;

%% add ID
%    derivedOriginID = docNode.createElement('derivedOriginID');
%    momenttensor.appendChild(derivedOriginID);
%    derivedOriginID.appendChild(docNode.createTextNode('smi:org.globalcmt/origin/C200501010120A'));
% 
%% add nodal planes
    nodalplanes = docNode.createElement('nodalPlanes');
    momenttensor.appendChild(nodalplanes );
%
      nodalPlane1 = docNode.createElement('nodalPlane1');
      nodalplanes.appendChild(nodalPlane1);

% strike 1
      strike1 = docNode.createElement('strike');
      nodalPlane1.appendChild(strike1);
             strike1_value=docNode.createElement('value');
             strike1.appendChild(strike1_value);  
             strike1_value.appendChild(docNode.createTextNode(str1));

% dip 1
      dip1 = docNode.createElement('dip');
      nodalPlane1.appendChild(dip1);
             dip1_value=docNode.createElement('value');
             dip1.appendChild(dip1_value);  
             dip1_value.appendChild(docNode.createTextNode(dp1));
             
% rake 1
      rake1 = docNode.createElement('rake');
      nodalPlane1.appendChild(rake1);
             rake1_value=docNode.createElement('value');
             rake1.appendChild(rake1_value);  
             rake1_value.appendChild(docNode.createTextNode(rk1));             
             
%% nodal plane 2             
      nodalPlane2 = docNode.createElement('nodalPlane2');
      nodalplanes.appendChild(nodalPlane2);   
      
% strike 2
      strike2 = docNode.createElement('strike');
      nodalPlane2.appendChild(strike2);
             strike2_value=docNode.createElement('value');
             strike2.appendChild(strike2_value);  
             strike2_value.appendChild(docNode.createTextNode(str2));

% dip 2
      dip2 = docNode.createElement('dip');
      nodalPlane2.appendChild(dip2);
             dip2_value=docNode.createElement('value');
             dip2.appendChild(dip2_value);  
             dip2_value.appendChild(docNode.createTextNode(dp2));
             
% rake 2
      rake2 = docNode.createElement('rake');
      nodalPlane2.appendChild(rake2);
             rake2_value=docNode.createElement('value');
             rake2.appendChild(rake2_value);  
             rake2_value.appendChild(docNode.createTextNode(rk2));              
             
%% add axes
    prinaxes = docNode.createElement('principalAxes');
    momenttensor.appendChild(prinaxes);
%
      tAxis = docNode.createElement('tAxis');
      prinaxes.appendChild(tAxis);

% azimuth
      azimuthT = docNode.createElement('azimuth');
      tAxis.appendChild(azimuthT);
             azimuthT_value=docNode.createElement('value');
             azimuthT.appendChild(azimuthT_value);  
             azimuthT_value.appendChild(docNode.createTextNode(tazm));

% plunge
      pluT = docNode.createElement('plunge');
      tAxis.appendChild(pluT);
             pluT_value=docNode.createElement('value');
             pluT.appendChild(pluT_value);  
             pluT_value.appendChild(docNode.createTextNode(tplng));

% length
      lenT = docNode.createElement('length');
      tAxis.appendChild(lenT);
             lenT_value=docNode.createElement('value');
             lenT.appendChild(lenT_value);  
             lenT_value.appendChild(docNode.createTextNode(tlngth));

% p axis
%
      pAxis = docNode.createElement('pAxis');
      prinaxes.appendChild(pAxis);

% azimuth
      azimuthP = docNode.createElement('azimuth');
      pAxis.appendChild(azimuthP);
             azimuthP_value=docNode.createElement('value');
             azimuthP.appendChild(azimuthP_value);  
             azimuthP_value.appendChild(docNode.createTextNode(pazm));

% plunge
      pluP = docNode.createElement('plunge');
      pAxis.appendChild(pluP);
             pluP_value=docNode.createElement('value');
             pluP.appendChild(pluP_value);  
             pluP_value.appendChild(docNode.createTextNode(pplng));

% length
      lenP = docNode.createElement('length');
      pAxis.appendChild(lenP);
             lenP_value=docNode.createElement('value');
             lenP.appendChild(lenP_value);  
             lenP_value.appendChild(docNode.createTextNode(plngth));

% n axis
%
      nAxis = docNode.createElement('nAxis');
      prinaxes.appendChild(nAxis);

% azimuth
      azimuthN = docNode.createElement('azimuth');
      nAxis.appendChild(azimuthN);
             azimuthN_value=docNode.createElement('value');
             azimuthN.appendChild(azimuthN_value);  
             azimuthN_value.appendChild(docNode.createTextNode(nazm));

% plunge
      pluN = docNode.createElement('plunge');
      nAxis.appendChild(pluN);
             pluN_value=docNode.createElement('value');
             pluN.appendChild(pluN_value);  
             pluN_value.appendChild(docNode.createTextNode(nplng));

% length
      lenN = docNode.createElement('length');
      nAxis.appendChild(lenN);
             lenN_value=docNode.createElement('value');
             lenN.appendChild(lenN_value);  
             lenN_value.appendChild(docNode.createTextNode(nlngth));

%% add creation info
    info = docNode.createElement('creationInfo');
    momenttensor.appendChild(info);  
    info_value=docNode.createElement('author');
    info.appendChild(info_value);
    info_value.appendChild(docNode.createTextNode(auth));
    
%% add moment tensor
    momentT = docNode.createElement('momentTensor');
    momenttensor.appendChild(momentT);

    % assign Name and Value attributes
     momentT.setAttribute('clvd',nclvd);
     momentT.setAttribute('doubleCouple',nDC);
     momentT.setAttribute('iso',niso);
     
     
%% add scalar moment
    smom = docNode.createElement('scalarMoment');
    momenttensor.appendChild(smom);  
        smom_value=docNode.createElement('value');
        smom.appendChild(smom_value);  
        smom_value.appendChild(docNode.createTextNode(mmom));
          
%% add tensor
    tensor = docNode.createElement('tensor');
    momenttensor.appendChild(tensor);
    
%%  MRR  
        Mrr = docNode.createElement('Mrr');
        tensor.appendChild(Mrr);
             Mrr_value=docNode.createElement('value');
             Mrr.appendChild(Mrr_value);  
             Mrr_value.appendChild(docNode.createTextNode(nMrr));
%%  MTT 
        Mtt = docNode.createElement('Mtt');
        tensor.appendChild(Mtt);
             Mtt_value=docNode.createElement('value');
             Mtt.appendChild(Mtt_value);  
             Mtt_value.appendChild(docNode.createTextNode(nMtt));
%%  MPP 
        Mpp = docNode.createElement('Mpp');
        tensor.appendChild(Mpp);
             Mpp_value=docNode.createElement('value');
             Mpp.appendChild(Mpp_value);  
             Mpp_value.appendChild(docNode.createTextNode(nMpp));
%%  MRT 
        Mrt = docNode.createElement('Mrt');
        tensor.appendChild(Mrt);
             Mrt_value=docNode.createElement('value');
             Mrt.appendChild(Mrt_value);  
             Mrt_value.appendChild(docNode.createTextNode(nMrt));
%%  MRP 
        Mrp = docNode.createElement('Mrp');
        tensor.appendChild(Mrp);
             Mrp_value=docNode.createElement('value');
             Mrp.appendChild(Mrp_value);  
             Mrp_value.appendChild(docNode.createTextNode(nMrp));
%%  MTP 
        Mtp = docNode.createElement('Mtp');
        tensor.appendChild(Mtp);
             Mtp_value=docNode.createElement('value');
             Mtp.appendChild(Mtp_value);  
             Mtp_value.appendChild(docNode.createTextNode(nMtp));               
          
% %% add time
%     time = docNode.createElement('time');
%     momenttensor.appendChild(time);
% %% add latitude
%     lat = docNode.createElement('latitude');
%     momenttensor.appendChild(lat);
% %% add longitude
%     long = docNode.createElement('longitude');
%     momenttensor.appendChild(long);
% %% add depth
%     depth = docNode.createElement('depth');
%     momenttensor.appendChild(depth);
% %% add mag
%     mag = docNode.createElement('magnitude');
%     momenttensor.appendChild(mag);
% %% add mag type
%     magtype = docNode.createElement('type');
%     momenttensor.appendChild(magtype);

             
%%
 xmlFileName = 'test.xml';
 xmlwrite(xmlFileName,docNode);
 
 
 
 ok=1;
 
 
 
 
 
 
 
 