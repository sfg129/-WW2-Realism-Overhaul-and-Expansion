#include "tracker.as"
#include "helpers.as"
#include "log.as"
#include "query_helpers.as"

class HawkinsMineV3 {
    Vector3 position;
    int owner;
    int faction;
    float life = 1200.0f;
    bool spent = false;
    HawkinsMineV3(Vector3 p, int c, int f) { position=p; owner=c; faction=f; }
}

class HawkinsGrenadeTracker : Tracker {
    protected Metagame@ m_metagame;
    protected array<HawkinsMineV3@> m_mines;
    protected float REMOTE_OFFSET_X = 0.20f;
    HawkinsGrenadeTracker(Metagame@ metagame) { @m_metagame = @metagame; }
    bool hasStarted() const { return true; }
    bool hasEnded() const { return false; }
    void onAdd() { _log("HawkinsNativeDisarm ready: native vehicle impact, no damage pulse", 1); }
    void onRemove() { m_mines.resize(0); }

    protected void spawn(string key, Vector3 p, int faction, int owner=-1) {
        string c = "<command class='create_instance' instance_class='grenade'" +
            " instance_key='" + key + "' position='" + p.toString() + "'";
        if (faction >= 0) c += " faction_id='" + faction + "'";
        if (owner >= 0) c += " character_id='" + owner + "'";
        c += " />";
        m_metagame.getComms().send(c);
    }

    // Only the instantaneous blast gets a character association; the body
    // remains ownerless and survives the original player's death.
    protected int blastCharacter(HawkinsMineV3@ mine) {
        if (mine.faction<0) return -1;
        const XmlElement@ original=getCharacterInfo(m_metagame,mine.owner);
        if (original !is null && original.getIntAttribute("dead")==0 &&
            original.getIntAttribute("faction_id")==mine.faction) return mine.owner;
        array<const XmlElement@>@ allies=getCharacters(m_metagame,mine.faction);
        if (allies !is null) {
            for (uint i=0; i<allies.length(); ++i) {
                int id=allies[i].getIntAttribute("id");
                if (id<0) continue;
                const XmlElement@ info=getCharacterInfo(m_metagame,id);
                if (info !is null && info.getIntAttribute("dead")==0 &&
                    info.getIntAttribute("faction_id")==mine.faction) return id;
            }
        }
        _log("HawkinsNativeDisarm no living faction character; faction-only blast fallback",1);
        return -1;
    }
    protected int nearest(Vector3 p, int owner, bool manual) {
        int found=-1;
        float best=1.0f;
        for (uint i=0; i<m_mines.length(); ++i) {
            if (manual && m_mines[i].owner != owner) continue;
            // Include spent records: a stale proxy must not fire a nearby mine.
            float d=getPositionDistance(p,m_mines[i].position);
            if (d<best) { best=d; found=int(i); }
        }
        return found;
    }

    protected void handleResultEvent(const XmlElement@ event) {
        string key=event.getStringAttribute("key");
        if (key!="hawkins_v3_arm" && key!="hawkins_v3_body" && key!="hawkins_v3_manual") return;
        Vector3 p=stringToVector3(event.getStringAttribute("position"));
        int owner=event.getIntAttribute("character_id");
        _log("HawkinsNativeDisarm event " + key + " at " + p.toString() + " owner=" + owner,1);
        if (key=="hawkins_v3_arm") {
            int faction=-1;
            const XmlElement@ info=getCharacterInfo(m_metagame,owner);
            if (info !is null) faction=info.getIntAttribute("faction_id");
            // Lift the spawn above the contact plane to avoid embedding it.
            Vector3 placed=p;
            placed.m_values[1]+=0.25f;
            m_mines.insertLast(HawkinsMineV3(placed,owner,faction));
            spawn("hawkins_grenade_armed.projectile",placed,faction);
            if (info !is null && owner>=0) {
                Vector3 remote=placed;
                remote.m_values[0]+=REMOTE_OFFSET_X;
                spawn("hawkins_grenade_remote_proxy.projectile",remote,faction,owner);
                _log("HawkinsNativeDisarm remote placed at " + remote.toString(),1);
            }
            return;
        }
        bool manual=key=="hawkins_v3_manual";
        Vector3 matchPosition=p;
        if (manual) matchPosition.m_values[0]-=REMOTE_OFFSET_X;
        int index=nearest(matchPosition,owner,manual);
        if (index<0) {
            _log("HawkinsNativeDisarm unmatched event; no speculative explosion",1);
            return;
        }
        HawkinsMineV3@ mine=m_mines[uint(index)];
        if (mine.spent) {
            _log("HawkinsNativeDisarm suppressed spent body/proxy event",1);
            return;
        }
        // A disappearing proxy must not detonate a mine after owner death.
        if (manual) {
            const XmlElement@ info=getCharacterInfo(m_metagame,mine.owner);
            if (info is null || info.getIntAttribute("dead")!=0) {
                _log("HawkinsNativeDisarm ignored proxy event from dead/missing owner",1);
                return;
            }
        }
        // Mark BEFORE send. The blast can trigger the physical body as well.
        mine.spent=true;
        Vector3 blastPosition=p;
        if (manual) blastPosition=mine.position;
        _log("HawkinsNativeDisarm BLAST ONCE at " + blastPosition.toString(),1);
        int sourceCharacter=blastCharacter(mine);
        _log("HawkinsNativeDisarm blast faction=" + mine.faction + " character=" + sourceCharacter,1);
        spawn("hawkins_grenade_blast.projectile",blastPosition,mine.faction,sourceCharacter);
    }

    void update(float time) {
        for (int i=int(m_mines.length())-1; i>=0; --i) {
            m_mines[uint(i)].life-=time;
            if (m_mines[uint(i)].life<=0.0f) m_mines.removeAt(uint(i));
        }
    }
}
