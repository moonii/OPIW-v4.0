package org.openpaas.ieda.hbdeploy.web.information.directorStemcellMgnt.service;

import java.security.Principal;
import java.util.Arrays;

import org.apache.commons.httpclient.Header;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethodBase;
import org.apache.commons.httpclient.methods.DeleteMethod;
import org.openpaas.ieda.hbdeploy.api.director.utility.DirectorRestHelper;
import org.openpaas.ieda.deploy.web.config.setting.dao.DirectorConfigVO;
import org.openpaas.ieda.hbdeploy.web.config.setting.service.HbDirectorConfigService;
import org.openpaas.ieda.hbdeploy.web.config.setting.dao.HbDirectorConfigVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class HbStemcellDeleteAsyncService {
    
    @Autowired private SimpMessagingTemplate messagingTemplate;
    @Autowired private HbDirectorConfigService hbDirectorConfigService;
    
    final private static String MESSAGE_ENDPOINT  = "/info/stemcell/delete/logs"; 
    
    /***************************************************
     * @project : Paas 플랫폼 설치 자동화
     * @description : 업로드된 스템셀 삭제 요청
     * @title : deleteStemcell
     * @return : void
    ***************************************************/
    public void deleteStemcell(String stemcellName, String stemcellVersion, Principal principal ) {
        //선택된 디렉터 정보 조회
        HbDirectorConfigVO selectedDirector = hbDirectorConfigService.getDirectorInfo(directorUrl, port, userId, password);
        try {
            HttpClient httpClient = DirectorRestHelper.getHttpClient(selectedDirector.getDirectorPort());
            DeleteMethod deleteMethod = new DeleteMethod(DirectorRestHelper.getDeleteStemcellURI(selectedDirector.getDirectorUrl(), selectedDirector.getDirectorPort(), stemcellName, stemcellVersion));
            deleteMethod = (DeleteMethod)DirectorRestHelper.setAuthorization(selectedDirector.getUserId(), selectedDirector.getUserPassword(), (HttpMethodBase)deleteMethod);
            
            //Request에 대한 응답
            int statusCode = httpClient.executeMethod(deleteMethod);
            if ( statusCode == HttpStatus.MOVED_PERMANENTLY.value() || statusCode == HttpStatus.MOVED_TEMPORARILY.value()    ) {
                
                Header location = deleteMethod.getResponseHeader("Location");
                String taskId = DirectorRestHelper.getTaskId(location.getValue());
                DirectorRestHelper.trackToTask(selectedDirector, messagingTemplate, MESSAGE_ENDPOINT, httpClient, taskId, "event", principal.getName());
                
            } else {
                DirectorRestHelper.sendTaskOutput(principal.getName(), messagingTemplate, MESSAGE_ENDPOINT, "error", Arrays.asList("스템셀 삭제 중 오류가 발생하였습니다."));
            }
        } catch ( RuntimeException e) {
            DirectorRestHelper.sendTaskOutput(principal.getName(), messagingTemplate, MESSAGE_ENDPOINT, "error", Arrays.asList("스템셀 삭제 중 Exception이 발생하였습니다."));
        } catch ( Exception e) {
            DirectorRestHelper.sendTaskOutput(principal.getName(), messagingTemplate, MESSAGE_ENDPOINT, "error", Arrays.asList("스템셀 삭제 중 Exception이 발생하였습니다."));
        }

    }

    /***************************************************
     * @project : Paas 플랫폼 설치 자동화
     * @description : 비동기 처리방식으로 deleteStemcell 메소드 호출
     * @title : deleteStemcellAsync
     * @return : void
    ***************************************************/
    @Async
    public void deleteStemcellAsync(String stemcellName, String stemcellVersion, Principal principal) {
        deleteStemcell(stemcellName, stemcellVersion, principal);
    }    
}
