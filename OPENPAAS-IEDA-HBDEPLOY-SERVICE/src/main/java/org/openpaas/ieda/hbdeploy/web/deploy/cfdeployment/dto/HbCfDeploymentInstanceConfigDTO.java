package org.openpaas.ieda.hbdeploy.web.deploy.cfdeployment.dto;

import java.util.Date;

public class HbCfDeploymentInstanceConfigDTO {
    private Integer id;
    private String instanceConfigName; // 
    private String iaasType; // 클라우드 인프라 환경 타입
    private String cfDeploymentName;
    private String cfDeploymentVersion;
    private String adapter;
    private String api;
    private String ccWorker;
    private String consul;
    private String theDatabase;
    private String diegoApi;
    private String diegoCell;
    private String haproxy;
    private String doppler;
    private String logApi;
    private String nats;
    private String router;
    private String singletonBlobstore;
    private String tcpRouter;
    private String uaa;
    private String scheduler;
    private String createUserId;//등록자 아이디
    private String updateUserId;//수정자 아이디
    private Date createDate;//등록일
    private Date updateDate;//수정일

    private String azsAdapter;
    private String azsApi;
    private String azsCcWorker;
    private String azsConsul;
    private String azsTheDatabase;
    private String azsDiegoApi;
    private String azsDiegoCell;
    private String azsHaproxy;
    private String azsDoppler;
    private String azsLogApi;
    private String azsNats;
    private String azsRouter;
    private String azsSingletonBlobstore;
    private String azsTcpRouter;
    private String azsUaa;
    private String azsScheduler;

    public Integer getId() {
        return id;
    }
    public void setId(Integer id) {
        this.id = id;
    }
    public String getInstanceConfigName() {
        return instanceConfigName;
    }
    public void setInstanceConfigName(String instanceConfigName) {
        this.instanceConfigName = instanceConfigName;
    }
    public String getIaasType() {
        return iaasType;
    }
    public void setIaasType(String iaasType) {
        this.iaasType = iaasType;
    }
    public String getCfDeploymentName() {
        return cfDeploymentName;
    }
    public void setCfDeploymentName(String cfDeploymentName) {
        this.cfDeploymentName = cfDeploymentName;
    }
    public String getCfDeploymentVersion() {
        return cfDeploymentVersion;
    }
    public void setCfDeploymentVersion(String cfDeploymentVersion) {
        this.cfDeploymentVersion = cfDeploymentVersion;
    }
    public String getAdapter() { return adapter; }
    public void setAdapter(String adapter) {
        this.adapter = adapter;
    }
    public String getApi() {
        return api;
    }
    public void setApi(String api) {
        this.api = api;
    }
    public String getCcWorker() {
        return ccWorker;
    }
    public void setCcWorker(String ccWorker) {
        this.ccWorker = ccWorker;
    }
    public String getConsul() {
        return consul;
    }
    public void setConsul(String consul) {
        this.consul = consul;
    }

    public String getTheDatabase() {
        return theDatabase;
    }
    public void setTheDatabase(String theDatabase) {
        this.theDatabase = theDatabase;
    }
    public String getDiegoApi() {
        return diegoApi;
    }
    public void setDiegoApi(String diegoApi) {
        this.diegoApi = diegoApi;
    }
    public String getDiegoCell() {
        return diegoCell;
    }
    public void setDiegoCell(String diegoCell) {
        this.diegoCell = diegoCell;
    }
    public String getHaproxy() {
        return haproxy;
    }
    public void setHaproxy(String haproxy) {
        this.haproxy = haproxy;
    }
    public String getDoppler() {
        return doppler;
    }
    public void setDoppler(String doppler) {
        this.doppler = doppler;
    }
    public String getLogApi() {
        return logApi;
    }
    public void setLogApi(String logApi) {
        this.logApi = logApi;
    }
    public String getNats() {
        return nats;
    }
    public void setNats(String nats) {
        this.nats = nats;
    }
    public String getRouter() {
        return router;
    }
    public void setRouter(String router) {
        this.router = router;
    }
    public String getSingletonBlobstore() {
        return singletonBlobstore;
    }
    public void setSingletonBlobstore(String singletonBlobstore) {
        this.singletonBlobstore = singletonBlobstore;
    }
    public String getTcpRouter() {
        return tcpRouter;
    }
    public void setTcpRouter(String tcpRouter) {
        this.tcpRouter = tcpRouter;
    }
    public String getUaa() {
        return uaa;
    }
    public void setUaa(String uaa) {
        this.uaa = uaa;
    }
    public String getScheduler() {
        return scheduler;
    }
    public void setScheduler(String scheduler) {
        this.scheduler = scheduler;
    }
    public String getCreateUserId() {
        return createUserId;
    }
    public void setCreateUserId(String createUserId) {
        this.createUserId = createUserId;
    }
    public String getUpdateUserId() {
        return updateUserId;
    }
    public void setUpdateUserId(String updateUserId) {
        this.updateUserId = updateUserId;
    }
    public Date getCreateDate() {
        return createDate;
    }
    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }
    public Date getUpdateDate() {
        return updateDate;
    }
    public void setUpdateDate(Date updateDate) {
        this.updateDate = updateDate;
    }

    public String getAzsAdapter() { return azsAdapter; }
    public void setAzsAdapter(String azsAdapter) { this.azsAdapter = azsAdapter; }
    public String getAzsApi() { return azsApi; }
    public void setAzsApi(String azsApi) { this.azsApi = azsApi; }
    public String getAzsCcWorker() { return azsCcWorker; }
    public void setAzsCcWorker(String azsCcWorker) { this.azsCcWorker = azsCcWorker; }
    public String getAzsConsul() { return azsConsul; }
    public void setAzsConsul(String azsConsul) { this.azsConsul = azsConsul; }
    public String getAzsTheDatabase() { return azsTheDatabase; }
    public void setAzsTheDatabase(String azsTheDatabase) { this.azsTheDatabase = azsTheDatabase; }
    public String getAzsDiegoApi() { return azsDiegoApi; }
    public void setAzsDiegoApi(String azsDiegoApi) { this.azsDiegoApi = azsDiegoApi; }
    public String getAzsDiegoCell() { return azsDiegoCell; }
    public void setAzsDiegoCell(String azsDiegoCell) { this.azsDiegoCell = azsDiegoCell; }
    public String getAzsHaproxy() { return azsHaproxy; }
    public void setAzsHaproxy(String azsHaproxy) { this.azsHaproxy = azsHaproxy; }
    public String getAzsDoppler() { return azsDoppler; }
    public void setAzsDoppler(String azsDoppler) { this.azsDoppler = azsDoppler; }
    public String getAzsLogApi() { return azsLogApi; }
    public void setAzsLogApi(String azsLogApi) { this.azsLogApi = azsLogApi; }
    public String getAzsNats() { return azsNats; }
    public void setAzsNats(String azsNats) { this.azsNats = azsNats; }
    public String getAzsRouter() { return azsRouter; }
    public void setAzsRouter(String azsRouter) { this.azsRouter = azsRouter; }
    public String getAzsSingletonBlobstore() { return azsSingletonBlobstore; }
    public void setAzsSingletonBlobstore(String azsSingletonBlobstore) { this.azsSingletonBlobstore = azsSingletonBlobstore; }
    public String getAzsTcpRouter() { return azsTcpRouter; }
    public void setAzsTcpRouter(String azsTcpRouter) { this.azsTcpRouter = azsTcpRouter; }
    public String getAzsUaa() { return azsUaa; }
    public void setAzsUaa(String azsUaa) { this.azsUaa = azsUaa; }
    public String getAzsScheduler() { return azsScheduler; }
    public void setAzsScheduler(String azsScheduler) { this.azsScheduler = azsScheduler; }
}
