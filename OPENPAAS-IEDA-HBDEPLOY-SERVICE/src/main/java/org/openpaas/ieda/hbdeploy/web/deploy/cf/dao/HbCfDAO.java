package org.openpaas.ieda.hbdeploy.web.deploy.cf.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

public interface HbCfDAO {
	
    /****************************************************************
     * @project : Paas 이종 플랫폼 설치 자동화
     * @description : CF 정보 목록 전체 조회
     * @title : selectHbCfInfoList
     * @return : List<HbCfVO>
    *****************************************************************/
	List<HbCfVO> selectHbCfInfoList(@Param("installStatus") String installStatus);
	
    /****************************************************************
     * @project : Paas 이종 플랫폼 설치 자동화
     * @description : CF 중복 데이터 확인
     * @title : selectHbCfInfoByName
     * @return : int
    *****************************************************************/
	int selectHbCfInfoByName(@Param("cfConfigName") String cfConfigName);
	
    /****************************************************************
     * @project : Paas 이종 플랫폼 설치 자동화
     * @description : CF 상세 조회
     * @title : selectHbCfInfoById
     * @return : HbCfVO
    *****************************************************************/
	HbCfVO selectHbCfInfoById(@Param("id") int id);

    /****************************************************************
     * @project : Paas 이종 플랫폼 설치 자동화
     * @description : CF 정보 삽입
     * @title : insertHbCfInfo
     * @return : void
    *****************************************************************/
	void insertHbCfInfo(@Param("vo") HbCfVO vo);
	
    /****************************************************************
     * @project : Paas 이종 플랫폼 설치 자동화
     * @description : CF 정보 수정
     * @title : updateHbCfInfo
     * @return : void
    *****************************************************************/
	void updateHbCfInfo(@Param("vo") HbCfVO vo);
	
    /****************************************************************
     * @project : Paas 이종 플랫폼 설치 자동화
     * @description : CF 정보 수정
     * @title : deleteHbCfInfo
     * @return : void
    *****************************************************************/
	void deleteHbCfInfo(@Param("id") int id);

}