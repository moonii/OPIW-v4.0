package org.openpaas.ieda.hbdeploy.web.config.setting.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

public interface HbDirectorConfigDAO {
    
    /***************************************************
     * @project : Paas 플랫폼 설치 자동화
     * @description : 디렉터 추가
     * @title : insertDirector
     * @return : int
    ***************************************************/
    int insertHbDirector(@Param("director")HbDirectorConfigVO directorConfig);
    
    /***************************************************
    * @project : Paas 플랫폼 설치 자동화
    * @description :: 디렉터 삭제
    * @title :deleteDirecotr
    * @return : int
    ***************************************************/
    int deleteHbDirector(@Param("seq")Integer seq);
    
    /***************************************************
    * @param directorType 
     * @project : Paas 플랫폼 설치 자동화
    * @description :: 디렉터 전체 목록 조회
    * @title :selectDirectorConfig
    * @return : List<HbDirectorConfigVO>
    ***************************************************/
    List<HbDirectorConfigVO> selectHbDirectorConfig(@Param("directorType") String directorType);
    
    
    /***************************************************
    * @project : Paas 플랫폼 설치 자동화
    * @description :: 디렉터 설정 조회
    * @title :selectDirectorConfigBySeq
    * @return : DirectorConfigVO
    ***************************************************/
    HbDirectorConfigVO selectHbDirectorConfigBySeq(@Param("seq")Integer seq);
    
    /***************************************************
    * @project : Paas 플랫폼 설치 자동화
    * @description :: 디렉터 존재 여부 확인
    * @title :selectDirectorConfigByDirectorUrl
    * @return : List<DirectorConfigVO>
    ***************************************************/
    List<HbDirectorConfigVO> selectHbDirectorConfigByDirectorUrl(@Param("directorUrl")String directorUrl);

    /***************************************************
    * @project : Paas 플랫폼 설치 자동화
    * @description :: 디렉터 존재 여부 확인
    * @title :selectDirectorConfigByDirectorUrl
    * @return : List<DirectorConfigVO>
    ***************************************************/
	HbDirectorConfigVO selectHbDirectorConfigInfoByDirectorNameAndCPI(@Param("director_cpi")String cpi, @Param("director_name")String directorName);

}
